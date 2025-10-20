# はじめに

node.jsで作成アプリについて、GCPへアップロードし、UPするまでの流れを記載する

## 作業ディレクトリの作成

```bash
# ディレクトリの移動
cd /

# アプリ用のフォルダ作成
mkdir app

# 環境用フォルダの作成
mkdir deploy
```

## デプロイ用のスクリプトファイル作成

```bash
#!/bin/bash

# アプリケーションのソースコード用ディレクトリを作成
sudo mkdir -p /app/src

# ディレクトリの所有権をユーザーに変更
sudo chown -R $USER:$USER /app/src

# ソースコードディレクトリに移動
cd /app/src

# Gitリポジトリアクセス用の認証情報を設定
USERNAME="hoge@hoge.co.jp"
PW="hoge"
# URLエンコードしてGitリポジトリURLに使用できる形式に変換
ENCODED_USERNAME=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$USERNAME'''))")
ENCODED_PW=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$PW'''))")

# リポジトリURLを構築
REPO_URL="https://${ENCODED_USERNAME}:${ENCODED_PW}@hoge.com/git/hoge.git"

# リポジトリをクローン
sudo git clone "$REPO_URL" .

# ソースコードディレクトリに移動
cd /app/src/src

# 依存パッケージをインストール
sudo npm install

# アプリケーションをビルド
sudo npm run build

# 既存のアプリケーションを停止
sudo pm2 stop hoge-app

# ビルドされたアプリケーションを本番環境にコピー
sudo cp -r .output /app

# ソースコードディレクトリを削除（セキュリティのため）
sudo rm -r /app/src

# アプリケーションディレクトリに移動
cd /app

# アプリケーションをPM2で起動
sudo pm2 start .output/server/index.mjs --name hoge-app

# PM2の設定を保存
sudo pm2 save
```

## 環境変数の作成

```bash
# ディレクトリの移動
cd /app

# 環境変数用ファイルの作成
sudo vim .env
```

環境変数値の設定値のサンプル

```bash
# アプリケーションの実行環境
NODE_ENV=
# 環境チェック用の変数
CHECK_ENV=
# アプリケーションのホスト名
HOST=
# アプリケーションのポート番号
PORT=
# アプリケーションのURL
APP_URL=
# APIのベースURL
API_URL=
# ハッシュ化に使用する秘密鍵
HASH_SECRET_KEY=
# Google Maps APIキー
MAP_API_KEY=
# Google Maps用のマップID
MAP_ID=
# Google OAuth認証用のクライアントID
GOOGLE_CLIENT_ID=
```

## 必要なアプリをインストール

```bash
# NodeSourceのリポジトリを追加し、Node.js 20.xのセットアップスクリプトを実行
# -f: エラー時に失敗を表示
# -s: サイレントモード（進行状況を表示しない）
# -S: エラー時にエラーを表示
# -L: リダイレクトに従う
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Node.jsをインストールする
sudo apt install -y nodejs

# Node.jsとnpmのバージョンを確認
node --version
npm --version
```

## バックグランド実行を導入する

```bash
# プロセスマネージャーPM2をグローバルにインストール
npm install -g pm2

# アプリケーションをPM2で起動し、"hoge-app"という名前で登録
bash pm2 start .output/server/index.mjs --name hoge-app

# 現在のPM2の設定を保存（再起動時に自動で起動するため）
bash pm2 save

# "hoge-app"という名前のアプリケーションを停止
bash pm2 stop hoge-app

# 実行中のPM2プロセス一覧を表示
bash pm2 list
```

## nginxのインストール

```bash
# パッケージリストを更新
sudo apt update

# Nginxをインストール
sudo apt install nginx

# Let's Encrypt用のcertbotとNginxプラグインをインストール
sudo apt install certbot python3-certbot-nginx
```

## nginxの設定値変更

```bash
# Nginxの設定ファイルを編集
sudo nano /etc/nginx/sites-available/hoge-app.hoge-app.com
```

以下内容とする
```js
server {
    # サーバー名の設定
    server_name hoge-app.hoge-app.com;

    location / {
        # Node.jsアプリケーションへのプロキシ設定
        proxy_pass http://localhost:3000;
        # HTTP/1.1を使用
        proxy_http_version 1.1;
        # WebSocketサポートの設定
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        # ホストヘッダーの設定
        proxy_set_header Host $host;
        # プロキシキャッシュのバイパス設定
        proxy_cache_bypass $http_upgrade;
    }

    # SSL設定（Certbotによって管理）
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/hoge-app.hoge-app.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/hoge-app.hoge-app.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
    # HTTPからHTTPSへのリダイレクト設定
    if ($host = hoge-app.hoge-app.com) {
        return 301 https://$host$request_uri;
    }

    # HTTP(80番ポート)でのリクエストを受け付け
    listen 80;
    server_name hoge-app.hoge-app.com;
    return 404;
}
```

## nginxの再起動

```bash
# 設定ファイルのシンボリックリンクを作成
sudo ln -s /etc/nginx/sites-available/hoge-app.hoge-app.com /etc/nginx/sites-enabled/

# Nginx設定ファイルの構文チェック
sudo nginx -t

# Nginxを再起動して新しい設定を適用
sudo systemctl restart nginx
```

## 不要なファイルの削除

```bash
# アプリケーションディレクトリに移動
cd /app

# ソースコードディレクトリを削除（デプロイ後は不要）
rm -r src
```

## httpsの設定

```bash
# Let's Encryptを使用してSSL証明書を取得・設定
# <DNS名>には実際のドメイン名を指定（例：hoge-app.hoge-app.com）
sudo certbot --nginx -d <DNS名>
```
