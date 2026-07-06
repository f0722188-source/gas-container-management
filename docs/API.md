# API 仕様

## ベース URL

```
http://localhost:8000/api
```

---

## エンドポイント一覧

### 容器管理 (Containers)

#### 容器一覧取得
```
GET /api/containers/
```

**レスポンス:**
```json
{
  "count": 10,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": "uuid",
      "serial_number": "GC-001",
      "container_type": {
        "id": "uuid",
        "name": "高圧容器 10L"
      },
      "status": "in_stock",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### 容器詳細取得
```
GET /api/containers/{id}/
```

#### 容器作成
```
POST /api/containers/
Content-Type: application/json

{
  "serial_number": "GC-001",
  "container_type_id": "uuid",
  "manufacturer": "ABC Corp",
  "manufacturing_date": "2023-01-01",
  "next_inspection_date": "2026-01-01"
}
```

#### 容器更新
```
PATCH /api/containers/{id}/
Content-Type: application/json

{
  "status": "in_stock"
}
```

---

### 出荷先管理 (Shipment Destinations)

#### 出荷先一覧取得
```
GET /api/shipment-destinations/
```

**レスポンス:**
```json
{
  "count": 5,
  "results": [
    {
      "id": "uuid",
      "name": "東京工場",
      "address": "東京都渋谷区...",
      "contact_person": "田中太郎",
      "phone": "03-xxxx-xxxx",
      "email": "tanaka@example.com"
    }
  ]
}
```

#### 出荷先作成
```
POST /api/shipment-destinations/
Content-Type: application/json

{
  "name": "新規出荷先",
  "address": "住所...",
  "contact_person": "連絡先...",
  "phone": "電話番号",
  "email": "メールアドレス"
}
```

#### 出荷先更新
```
PATCH /api/shipment-destinations/{id}/
```

#### 出荷先削除
```
DELETE /api/shipment-destinations/{id}/
```

---

### 出荷管理 (Shipments)

#### 出荷一覧取得
```
GET /api/shipments/
```

**パラメータ:**
- `status`: 'shipped', 'returned', 'returned_confirmed'
- `container_id`: フィルタ用
- `destination_id`: フィルタ用

**レスポンス:**
```json
{
  "count": 20,
  "results": [
    {
      "id": "uuid",
      "container": {
        "id": "uuid",
        "serial_number": "GC-001"
      },
      "destination": {
        "id": "uuid",
        "name": "東京工場"
      },
      "shipment_date": "2024-01-01",
      "status": "shipped",
      "notes": "備考"
    }
  ]
}
```

#### 出荷作成
```
POST /api/shipments/
Content-Type: application/json

{
  "container_id": "uuid",
  "destination_id": "uuid",
  "shipment_date": "2024-01-15",
  "notes": "出荷のメモ"
}
```

**バリデーション:**
- 容器が `in_stock` または `returned_pending` ステータスであることを確認
- 前回の出荷が返却確認済みであることを確認

---

### 返却管理 (Returns)

#### 返却一覧取得
```
GET /api/returns/
```

**レスポンス:**
```json
{
  "count": 15,
  "results": [
    {
      "id": "uuid",
      "shipment": {
        "id": "uuid",
        "container": {
          "serial_number": "GC-001"
        },
        "destination": {
          "name": "東京工場"
        }
      },
      "return_date": "2024-01-10",
      "condition": "good",
      "notes": "返却時のメモ"
    }
  ]
}
```

#### 返却作成
```
POST /api/returns/
Content-Type: application/json

{
  "shipment_id": "uuid",
  "return_date": "2024-01-10",
  "condition": "good",
  "notes": "返却時のメモ"
}
```

**処理内容:**
1. 対応する出荷記録が存在することを確認
2. 返却記録を作成
3. 容器のステータスを `returned_pending` に更新

---

### 容器履歴 (Container History)

#### 履歴一覧取得
```
GET /api/container-history/?container_id={id}
```

**レスポンス:**
```json
{
  "count": 10,
  "results": [
    {
      "id": "uuid",
      "container": {
        "serial_number": "GC-001"
      },
      "action": "shipped",
      "destination": {
        "name": "東京工場"
      },
      "action_date": "2024-01-15T10:00:00Z",
      "notes": "出荷時のメモ"
    }
  ]
}
```

---

## エラーレスポンス

### 400 Bad Request
```json
{
  "detail": "Invalid request data"
}
```

### 404 Not Found
```json
{
  "detail": "Not found"
}
```

### 409 Conflict (返却確認前の再出荷試行等)
```json
{
  "detail": "Container has not been returned from previous shipment"
}
```

---

## 認証（将来実装予定）

JWT トークンベースの認証を実装予定。

---

## ページネーション

デフォルト: 1ページ20件

```
?page=1&page_size=50
```
