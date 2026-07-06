# セットアップガイド

## 前提条件

- Python 3.10+
- PostgreSQL 13+
- Git

## 開発環境セットアップ

### 1. リポジトリをクローン

```bash
git clone https://github.com/f0722188-source/gas-container-management.git
cd gas-container-management
```

### 2. 仮想環境を作成

```bash
python -m venv venv

# Linux / macOS
source venv/bin/activate

# Windows
venv\Scripts\activate
```

### 3. 依存関係をインストール

```bash
pip install -r requirements.txt
```

### 4. PostgreSQL データベースを作成

```bash
psql -U postgres

# PostgreSQL プロンプト内
CREATE DATABASE gas_container_management;
CREATE USER gas_user WITH PASSWORD 'your_password';
ALTER ROLE gas_user SET client_encoding TO 'utf8';
ALTER ROLE gas_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE gas_user SET default_transaction_deferrable TO on;
ALTER ROLE gas_user SET timezone TO 'Asia/Tokyo';
GRANT ALL PRIVILEGES ON DATABASE gas_container_management TO gas_user;
\q
```

### 5. 環境変数を設定

`.env.example` を参考にして `.env` ファイルを作成：

```bash
cd backend
cp .env.example .env
```

`.env` の内容例：

```
DEBUG=True
SECRET_KEY=your-secret-key-here
DB_ENGINE=django.db.backends.postgresql
DB_NAME=gas_container_management
DB_USER=gas_user
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
ALLOWED_HOSTS=localhost,127.0.0.1
```

### 6. Django マイグレーションを実行

```bash
cd backend
python manage.py migrate
```

### 7. スーパーユーザーを作成

```bash
python manage.py createsuperuser
```

### 8. 開発サーバーを起動

```bash
python manage.py runserver
```

Django 開発サーバーが `http://localhost:8000` で起動します。

---

## Docker を使用したセットアップ（オプション）

### 1. Docker と Docker Compose をインストール

[Docker Desktop](https://www.docker.com/products/docker-desktop) をダウンロード・インストール

### 2. コンテナを起動

```bash
docker-compose up -d
```

### 3. マイグレーションを実行

```bash
docker-compose exec web python manage.py migrate
```

### 4. スーパーユーザーを作成

```bash
docker-compose exec web python manage.py createsuperuser
```

### 5. アプリケーションにアクセス

- Django: http://localhost:8000
- PostgreSQL: localhost:5432

---

## テスト実行

```bash
cd backend
python manage.py test
```

---

## 管理画面

Django Admin にアクセス：

```
http://localhost:8000/admin
```

スーパーユーザーの認証情報でログイン

---

## API エンドポイント

```
http://localhost:8000/api/
```

詳細は [API.md](API.md) を参照

---

## トラブルシューティング

### PostgreSQL 接続エラー

```
psycopg2.OperationalError: could not connect to server
```

**解決方法:**
- PostgreSQL が起動しているか確認
- 接続情報（ホスト、ユーザー、パスワード）を確認
- `psql` で直接接続テスト

```bash
psql -U gas_user -d gas_container_management -h localhost
```

### マイグレーションエラー

```bash
# キャッシュをクリア
python manage.py migrate --fake-initial
```

### ポート既に使用中

デフォルトポート（8000）が使用中の場合：

```bash
python manage.py runserver 8001
```
