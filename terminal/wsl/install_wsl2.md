ご提示いただいた内容をMarkdown形式で整理しました。

-----

# 💻 WSLのインストールと修復、およびDockerのセットアップ手順メモ

このメモは、WSL（Windows Subsystem for Linux）の機能有効化、修復、およびその後のDocker環境セットアップのために実行されたコマンドとその結果、および次に取るべき手順をまとめたものです。

## 1\. WSL関連機能の有効化と修復

| 実行コマンド | 実行結果の概要 | 備考 |
| :--- | :--- | :--- |
| `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart` | **成功** | WSLのコア機能を有効化。 |
| `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart` | **成功** | WSL 2に必要な仮想マシン機能を有効化。 |
| `wsl --update` | **エラー** (`Wsl/CallMsi/Install/REGDB_E_CLASSNOTREG`) | WSLのインストールが壊れている可能性が示唆された。 |
| `wsl --install` | **成功**（VirtualMachinePlatformのインストール） | 必要なコンポーネントがインストールされ、**再起動が必要**である旨のメッセージが表示された。 |

### 🚨 重要な指示

上記のコマンド実行により、システムの変更が要求されました。変更を完全に有効にするには、**システムを再起動する必要があります。**

> **要求された操作は正常に終了しました。変更を有効にするには、システムを再起動する必要があります。**

## 2\. 次のステップ：PCの再起動と動作確認

### 1\. PCを再起動する 🔄

`wsl --install`などで適用されたシステム変更を有効にするため、**すぐにPCを再起動してください。**

### 2\. 再起動後に動作を確認する ✅

再起動後、PowerShellまたはコマンドプロンプトを開き、以下のコマンドでWSLの状態を確認します。エラーなく情報が表示されれば修復は成功です。

```powershell
wsl --status
```

### 3\. Linuxディストリビューションをインストールする 🐧

修復が成功していれば、以下のコマンドでUbuntuをインストールします。インストール完了後、ユーザー名とパスワードを設定してください。

```powershell
wsl --install Ubuntu
```

-----

## 3\. WSL上でDockerをセットアップ（再起動後の作業）

以下のコマンドは、WSL内のLinuxディストリビューション（例：Ubuntu）で実行されたDockerのインストール手順です。

### 1\. パッケージリストの更新とアップグレード

```bash
sudo apt update && sudo apt upgrade -y
```

### 2\. Docker公式GPGキーの追加

```bash
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### 3\. Dockerリポジトリの追加

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 4\. 再度パッケージリストを更新

```bash
sudo apt update
```

### 5\. Docker関連パッケージのインストール

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### 6\. Dockerバージョンの確認

```bash
docker --version
```