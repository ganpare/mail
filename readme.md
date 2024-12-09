# メール送受信システム構築 - Dockerを利用したPostfix/Dovecot環境

## システム概要

このシステムは、Docker環境でメール送受信の基礎機能を提供するPostfix（SMTPサーバ）とDovecot（POP3サーバ）を構築したものです。構成はDNSサーバ、SMTPサーバ、アプリサーバ、POP3クライアントからなり、それぞれのコンテナが役割を分担しています。

---

## コンテナ構成

### 1. DNSサーバ (`dns-server`)
- **役割**:
  - メールの送受信に使用するドメイン名（`example.local`）の名前解決を担当。
- **設定内容**:
  - BINDを利用し、ゾーン情報を設定。
  - フォワードゾーンとリバースゾーンを設定。
- **主な設定ファイル**:
  - `named.conf`: ゾーン情報の定義。
  - `db.example.local`: 正引きゾーンファイル。
  - `db.19.172.in-addr.arpa`: 逆引きゾーンファイル。

---

### 2. SMTPサーバ (`smtp-server`)
- **役割**:
  - Postfixを使用してメールの送信（SMTP）とローカルメール配信を実現。
  - Dovecotを使用してメールの受信（POP3）を提供。
- **設定内容**:
  - Postfixでローカル配送を設定（Maildir形式でメールを保存）。
  - DovecotでPOP3プロトコルを有効化。
  - 各ユーザのホームディレクトリを`/var/mail/<ユーザ名>`に統一。
- **主な設定ファイル**:
  - Postfix:
    - `main.cf`: メール配送の基本設定。
    - `master.cf`: サービス設定。
  - Dovecot:
    - `dovecot.conf`: POP3の設定。
    - `/etc/dovecot/users`: 認証情報を管理。
- **補足**:
  - Postfixがメールをローカルユーザの`Maildir`に保存。
  - Dovecotがその`Maildir`を参照し、クライアントにメールを提供。

---

### 3. アプリサーバ (`app-server`)
- **役割**:
  - Pythonスクリプトを使用してSMTPサーバにメールを送信。
- **設定内容**:
  - `send_mail.py`を実行し、指定した宛先にメールを送信。
- **主な設定ファイル**:
  - `send_mail.py`: SMTPサーバにメールを送信するスクリプト。
- **補足**:
  - メール送信の動作確認用。

---

### 4. クライアント (`client`)
- **役割**:
  - POP3クライアントとしてSMTPサーバに接続し、メールを受信。
- **設定内容**:
  - `telnet`や`curl`を利用してPOP3サーバへ手動で接続。
  - `LIST`, `RETR`, `QUIT`コマンドで動作確認を実施。
- **補足**:
  - メール受信の確認用。

---

## 問題解決の流れ

### **問題1: POP3クライアントでメールが見えない**
- **原因**:
  - Postfixがシステムユーザのホームディレクトリ（`/home/test/Maildir`）にメールを保存。
  - 一方、Dovecotは`/var/mail/test/Maildir`を参照しており、参照先が一致しなかった。
- **解決策**:
  - Dockerfileでユーザのホームディレクトリを`/var/mail/<ユーザ名>`に設定。

---

### **問題2: メールがRFC準拠でない可能性**
- **原因**:
  - メール送信スクリプトで`From:`や`To:`ヘッダが省略されていた。
- **解決策**:
  - Pythonスクリプトに`From:`, `To:`, `Subject:`ヘッダを追加。

---

### **問題3: 配信メールの保存場所が未確認**
- **原因**:
  - 配信されたメールが`/home/test/Maildir`に保存されていたが、確認が遅れた。
- **解決策**:
  - Postfixログを確認し、メールの実際の保存先を調査。

---

## システム動作確認

1. **メール送信の確認**:
   - `app-server`から`send_mail.py`を実行し、SMTPサーバにメールを送信。
   - Postfixログで「`delivered to maildir`」を確認。

2. **メール受信の確認**:
   - `client`からPOP3サーバに接続。
   - `USER`, `PASS`, `LIST`, `RETR`コマンドでメールの受信を確認。

---

## システム全体図

```plaintext
+-----------------+      +-----------------+      +-----------------+      +-----------------+
|   DNS Server    | ---> |   SMTP Server   | ---> |  App Server     | ---> |  POP3 Client    |
| (dns-server)    |      | (smtp-server)   |      | (app-server)    |      | (client)        |
+-----------------+      +-----------------+      +-----------------+      +-----------------+
| Name Resolution |      | Send/Receive    |      | Send Mail        |      | Retrieve Mail   |
| example.local   |      | Maildir Storage |      | SMTP Protocol    |      | POP3 Protocol   |
+-----------------+      +-----------------+      +-----------------+      +-----------------+
