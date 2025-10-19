# はじめに

ssh関係のメモ

## 作成

### .sshフォルダの作成

```bash
New-Item -ItemType Directory -Path $env:USERPROFILE\.ssh -Force
```

### .sshキーの作成

```bash
ssh-keygen -t ed25519 -C "comment" -f $env:USERPROFILE\.ssh\id_ed25519_〇〇
```

| キーの種類 | 概要 |
| :--- | :--- |
| ed25519 | 通常のSSHキー（最新環境） |
| RSA 4096 | レガシー環境（古いサーバー） |

### .sshキーの登録

例でGitHubについて記載

- Get-Content $env:USERPROFILE\.ssh\id_ed25519_〇〇.pub
- 出力された公開鍵（ssh-ed25519 ... から始まる）をコピー
　※pub拡張子であること
- GitHubの「SSH and GPG keys」ページに行く
- 「New SSH Key」をクリック
- コピーした公開鍵を貼り付けて追加

## configファイルの作成

- sshキーと同じディレクトリにconfigファイルを作成
- キーごろに分けずにまとめて記載でOK

```bash
# GitHubメイン用
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_〇〇

# プロジェクトA用
Host github-projectA
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_projectA

# プロジェクトB用
Host github-projectB
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_projectB
```
