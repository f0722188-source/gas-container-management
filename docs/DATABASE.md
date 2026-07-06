# データベース設計

## ER 図と関連図

### テーブル一覧

1. **containers** - 高圧ガス容器
2. **container_types** - 容器型式
3. **shipments** - 出荷記録
4. **returns** - 返却記録
5. **shipment_destinations** - 出荷先
6. **container_history** - 容器の履歴

---

## テーブル定義

### containers (容器マスタ)

```sql
CREATE TABLE containers (
    id UUID PRIMARY KEY,
    container_type_id UUID NOT NULL,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    manufacturer VARCHAR(100),
    manufacturing_date DATE,
    next_inspection_date DATE,
    status VARCHAR(20) NOT NULL, -- 'in_stock', 'shipped', 'returned_pending'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (container_type_id) REFERENCES container_types(id)
);
```

**status の説明:**
- `in_stock`: 在庫中（出荷可能）
- `shipped`: 出荷中（返却待ち）
- `returned_pending`: 返却済み・出荷可能

---

### container_types (容器型式)

```sql
CREATE TABLE container_types (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity DECIMAL(10, 2), -- 容量（L）
    pressure_rating DECIMAL(10, 2), -- 圧力定格（MPa）
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### shipment_destinations (出荷先)

```sql
CREATE TABLE shipment_destinations (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### shipments (出荷記録)

```sql
CREATE TABLE shipments (
    id UUID PRIMARY KEY,
    container_id UUID NOT NULL,
    destination_id UUID NOT NULL,
    shipment_date DATE NOT NULL,
    quantity INT DEFAULT 1,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'shipped', -- 'shipped', 'returned', 'returned_confirmed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (container_id) REFERENCES containers(id),
    FOREIGN KEY (destination_id) REFERENCES shipment_destinations(id)
);
```

---

### returns (返却記録)

```sql
CREATE TABLE returns (
    id UUID PRIMARY KEY,
    shipment_id UUID NOT NULL,
    return_date DATE NOT NULL,
    condition VARCHAR(50), -- 容器の状態（'good', 'damaged', 'leak'等）
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id)
);
```

---

### container_history (容器履歴)

```sql
CREATE TABLE container_history (
    id UUID PRIMARY KEY,
    container_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'shipped', 'returned', 'status_changed'
    destination_id UUID,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (container_id) REFERENCES containers(id),
    FOREIGN KEY (destination_id) REFERENCES shipment_destinations(id)
);
```

---

## 重要なビジネスロジック

### 返却条件チェック

容器が別の出荷先に出荷される前に：

1. **最後の出荷記録を確認**
   ```
   SELECT * FROM shipments 
   WHERE container_id = ? 
   ORDER BY shipment_date DESC 
   LIMIT 1;
   ```

2. **その出荷が返却されているかチェック**
   ```
   SELECT r.id FROM returns r
   JOIN shipments s ON s.id = r.shipment_id
   WHERE s.id = last_shipment.id;
   ```

3. **返却が確認されている場合のみ、新規出荷を許可**

---

## インデックス

```sql
CREATE INDEX idx_containers_status ON containers(status);
CREATE INDEX idx_containers_serial ON containers(serial_number);
CREATE INDEX idx_shipments_container ON shipments(container_id);
CREATE INDEX idx_shipments_destination ON shipments(destination_id);
CREATE INDEX idx_shipments_date ON shipments(shipment_date);
CREATE INDEX idx_returns_shipment ON returns(shipment_id);
CREATE INDEX idx_history_container ON container_history(container_id);
```

---

## マイグレーション戦略

Django のマイグレーションシステムを使用します。詳細は `backend/apps/` のモデル定義を参照してください。
