# ADC構成手順書

## 概要
ADC(Application Default Credentials)とは、私たちがGoogle Cloudのサービスを利用する時に利用する認証情報をローカル環境に保存して置ける仕組みです。これにより、コードに認証情報を直接記述することなく、安全にGoogle Cloud APIにアクセスできます。

## ADC構成手順

### 1. Google Cloud CLIのインストール

まだGoogle Cloud CLIをインストールしていない場合は、以下の公式サイトからインストールしてください。
- Windows、macOS、Linuxの各OSに対応したインストーラーが提供されています。
- https://cloud.google.com/sdk/docs/install

### 2. アプリケーションデフォルト認証情報の設定

以下のコマンドを実行して、ADCをローカル環境に設定します。

```bash
gcloud auth application-default revoke
gcloud auth application-default login --no-launch-browser --scopes='https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/calendar'
```
※不足するscopesは[Google Cloud](https://developers.google.com/identity/protocols/oauth2/scopes?hl=ja)を参照して確認してください。
※リソースを消費するプロジェクトの指定を求められたときは`gcloud auth application-default set-quota-project techxpy`を実行してください。

### 3. 認証プロセスの完了

コマンド実行後、以下のようなメッセージとURLが表示されます：

```
Go to the following link in your browser:

    https://accounts.google.com/o/oauth2/auth?...（長いURL）

Enter authorization code:
```

1. 表示されたURLをコピーして、ブラウザに貼り付けてアクセスします
2. Googleアカウントでログインし、必要な権限を承認します
3. 認証が完了すると、認証コードが表示されます
4. 表示された認証コードをコピーして、ターミナルの「Enter authorization code:」プロンプトに貼り付けてEnterキーを押します
5. 認証が成功すると、以下のメッセージが表示され、認証情報が保存されます

```
Credentials saved to file: [/path/to/application_default_credentials.json]
```

認証情報は以下の場所に保存されます：
- Windows: `%APPDATA%\gcloud\application_default_credentials.json`
- macOS/Linux: `~/.config/gcloud/application_default_credentials.json`

`--no-launch-browser`オプションは、GUIがない環境や自動化されたスクリプト内で認証を行う場合に特に便利です。

### 6. 設定の確認

認証設定が正しく行われているか確認するには、以下のPythonコードを実行してみましょう。

```python
from google.cloud import storage

# ADCを使用して認証されます
client = storage.Client('techxpy')

# プロジェクト内のバケット一覧を取得
buckets = list(client.list_buckets())
print(f"プロジェクト内のバケット数: {len(buckets)}")
```
