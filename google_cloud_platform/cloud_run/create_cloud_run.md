# はじめに

Cloud Runを利用する手順をまとめる

今回、ローカルPCのコードからCloud Runにあげるため、"Artifact Registry"と"Cloud Build"を作成する


## Artifact Registryの作成

### Artifact Registryとは？？

- コンテナイメージやパッケージを保存する"倉庫（レジストリ）"
- Cloud Run / Cloud Functionsはここにあるコンテナイメージを参照して実行

### サンプル（GUI上で作成）

| 項目 | サンプル値 |
| :--- | :--- |
| 名前 | hoge |
| 形式 | Docker |
| モード | 標準 |
| ロケーションタイプ | リージョン・asia-northeast1 |
| 暗号化 | Googleが管理する暗号鍵 |
| 不要のイメージタグ | 無効 |
| クリーンアップポリシー | テストを実行（運用が安定したら変更） |
| Artifact Analysis | 有効 |
| 情弱性スキャン | 有効 |

## Cloud Buildとは？

ローカルPCのコードを一式送付することで、以下を実行できる
- Dockerイメージをbuild
- Artifact Registryにpush

### サンプル（CUIで作成）

- gcloudにログイン

```ps1
# もしgcloud実行にあたり、SSL照明が必要だったら（Netskope）
$env:SSL_CERT_FILE="C:\任意のフォルダ\hoge.pem"
$env:REQUESTS_CA_BUNDLE="C:\任意のフォルダ\hoge.pem"
```

```ps1
$PROJECT_ID = "YOUR_PROJECT_ID"
$REGION     = "asia-northeast1"
$REPOSITORY = "hoge"
$IMAGE      = "hoge"

# $($REGION)-docker.pkg.dev：リージョン別ホスト名
# latest:最新晩を指定
$IMAGE_URL  = "$($REGION)-docker.pkg.dev\$($PROJECT_ID)\$($REPOSITORY)\$($IMAGE):latest"

# ===== 事前準備 =====
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# ===== APIの有効か（GUIで操作でもOK） =====
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# ===== 実施 =====
# (1)Dockerfileをルートに一時コピー
#    理由：後で実行する"gcloud build submit"はカレント直下のDockerfileを自動検出するため
#    ※コピーしてもDockerfile内の相対パスはルート基準なのでその通り
Copy-Item -Force .\docker\Dockerfile .\Dockerfile

# (2)クラウド上でビルドして、Artifact Registryにpush
#    1)カレント配下のソースをCloud Buildにアップデート
#    2)ルートのDockerfileでDockerイメージをクラウド側でビルド
#    3)実行成功後
#      - Cloud Build > ビルド履歴にログが1件追加
#      - Artifact Registry > hogeに$IMAGE:latestが出現
gcloud builds submit --tag $IMAGE_URL
```

## Cloud Runの作成

### Cloud Runとは？

- 作成したコードをDockerベースでデプロイする

### 補足

- 作成後の実行
    - IAM管理しているため、gcloudでログインするかサービスアカウントから実行
    - 以下コマンドからテスト実行

    ```ps1
    # Cloud Shellで以下を実行 
    gcloud run services proxy hoge --region=asia-northeast1 --port=8080
    ```
