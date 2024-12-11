# Code Collection Report

## Directory Structure:
```
├── app-server/
│   ├── Dockerfile
│   └── send_mail.py
├── bind/
│   ├── db.19.172.in-addr.arpa
│   ├── db.example.local
│   ├── Dockerfile
│   ├── named.conf
│   └── rndc.key
├── client/
│   ├── Dockerfile
│   └── test_mail.sh
├── etc/
│   ├── dovecot/
│   │   ├── dovecot.conf
│   │   └── users
│   ├── postfix/
│   │   ├── main.cf
│   │   └── master.cf
│   ├── mailname
│   └── nsswitch.conf
├── smtp/
│   ├── Dockerfile
│   └── init.sh
├── docker-compose.yml
├── readme.md
├── smtp_aliases
└── よく使うコマンド.txt

```

### File: `docker-compose.yml`

**Language:** yml

**File Size:** 1604 bytes
**Created:** 2024-12-10T22:42:31.366498
**Modified:** 2024-12-10T23:16:36.523503

```yml
services:
  dns-server:
    build:
      context: ./ 
      dockerfile: ./bind/Dockerfile
    container_name: dns-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.3
    ports:
      - "53:53/udp"
    volumes:
      - ./bind:/etc/bind
    restart: always

  smtp-server:
    build:
      context: .
      dockerfile: ./smtp/Dockerfile
    container_name: smtp-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.4
    dns:
      - 172.19.0.3
    environment:
      MAILNAME: smtp.example.local
    ports:
      - "1025:25"
      - "110:110"  # POP3ポート追加
    volumes:
      - ./smtp_aliases:/etc/aliases
      - ./etc/dovecot:/etc/dovecot
      - mail_data:/var/mail  # 名前付きボリュームに変更
    restart: always
    depends_on:
      - dns-server
    cap_add:
      - SYSLOG

  app-server:
    build: ./app-server
    container_name: app-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.5
    dns:
      - 172.19.0.3
    environment:
      SMTP_SERVER: smtp.example.local
    depends_on:
      - dns-server
      - smtp-server
    command: ["sh", "-c", "python3 send_mail.py && tail -f /dev/null"]

  client:
    build: ./client
    container_name: client
    networks:
      mail_network:
        ipv4_address: 172.19.0.6
    dns:
      - 172.19.0.3
    stdin_open: true
    tty: true
    command: sleep infinity

networks:
  mail_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.19.0.0/16

volumes:
  mail_data:

```

### File: `readme.md`

**Language:** md

**File Size:** 4781 bytes
**Created:** 2024-12-10T21:19:52.454239
**Modified:** 2024-12-10T21:19:52.454239

```md
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

```

### File: `smtp_aliases`

**Language:** 

**File Size:** 36 bytes
**Created:** 2024-12-09T23:34:53.806898
**Modified:** 2024-12-09T23:34:53.807900

```
postmaster:    root
recipient: user
```

### File: `よく使うコマンド.txt`

**Language:** txt

**File Size:** 1406 bytes
**Created:** 2024-12-11T20:20:20.801213
**Modified:** 2024-12-11T20:20:20.802212

```txt
docker-compose down
docker-compose up --build -d
docker exec -it smtp-server nslookup example.local
docker exec -it app-server nslookup example.local
docker exec -it client nslookup example.local
docker exec -it app-server python3 /app/send_mail.py
docker exec -it smtp-server tail -f /var/log/mail.log

docker ps


docker exec -it dns-server bash
docker exec -it app-server bash
docker exec -it smtp-server bash
docker exec -it client sh


dig example.local @127.0.0.1
dig -x 172.19.0.4 @127.0.0.1


docker-compose build smtp-server
docker-compose up -d smtp-server

docker-compose build
docker-compose up -d


docker exec -it smtp-server ls -l /var/mail

docker exec -it smtp-server ls -ld /var/mail/test

docker exec -it smtp-server ls -ld /var/mail/test/Maildir


docker exec -it smtp-server ls -ld /var/mail/test/Maildir/new

docker exec -it smtp-server ls -ld /var/mail/test/Maildir/cur
docker exec -it smtp-server ls -ld /var/mail/test/Maildir/new
docker exec -it smtp-server ls -ld /var/mail/test/Maildir/tmp


docker exec -it smtp-server ls -l /var/mail/test/Maildir/cur
docker exec -it smtp-server ls -l /var/mail/test/Maildir/new
docker exec -it smtp-server ls -l /var/mail/test/Maildir/tmp


docker exec -it client sh
telnet smtp.example.local 110

USER test
PASS password
LIST
RETR 1
QUIT


docker-compose build --no-cache smtp-server

```

### File: `app-server\Dockerfile`

**Language:** 

**File Size:** 219 bytes
**Created:** 2024-12-07T09:44:08.388088
**Modified:** 2024-12-08T09:24:44.349179

```
FROM python:3.9-slim

WORKDIR /app

COPY send_mail.py ./

RUN apt-get update && apt-get install -y \
    iputils-ping \
    telnet \
    dnsutils

CMD ["sh", "-c", "python3 send_mail.py && tail -f /dev/null"]
```

### File: `app-server\send_mail.py`

**Language:** py

**File Size:** 948 bytes
**Created:** 2024-12-09T23:34:53.803900
**Modified:** 2024-12-09T23:34:53.803900

```py
import smtplib
import os

# デバッグログ
print("Starting email sending script...")

# SMTPサーバ情報
smtp_server = os.environ.get('SMTP_SERVER', 'smtp.example.local')
smtp_port = 25
print(f"Connecting to SMTP server: {smtp_server}:{smtp_port}")

# メール送信設定
from_email = "test@example.local"
to_email = "test@example.local"
subject = "Test Mail from App Server"
body = "This is a test email sent from app-server via dockerized SMTP server."

# メールフォーマットにFrom:やTo:ヘッダを追加
message = f"From: {from_email}\nTo: {to_email}\nSubject: {subject}\n\n{body}"


try:
    # SMTPサーバ接続とメール送信
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        print("Connected to SMTP server.")
        server.sendmail(from_email, to_email, message)
        print("Email sent successfully.")
except Exception as e:
    print("Error while sending email:", e)

```

### File: `bind\db.19.172.in-addr.arpa`

**Language:** arpa

**File Size:** 813 bytes
**Created:** 2024-12-09T23:34:53.804900
**Modified:** 2024-12-09T23:34:53.804900

```arpa
$TTL    86400
@       IN      SOA     example.local. root.example.local. (
                            2         ; Serial        ; シリアル番号を更新
                        604800         ; Refresh
                         86400         ; Retry
                       2419200         ; Expire
                         604800 )      ; Negative TTL
        IN      NS      ns.example.local.             ; ネームサーバーの指定
3       IN      PTR     ns.example.local.             ; ns のリバースエントリ
4       IN      PTR     smtp.example.local.           ; smtp のリバースエントリ
5       IN      PTR     app.example.local.            ; app のリバースエントリ
6       IN      PTR     client.example.local.         ; client のリバースエントリ


```

### File: `bind\db.example.local`

**Language:** local

**File Size:** 1436 bytes
**Created:** 2024-12-09T23:34:53.804900
**Modified:** 2024-12-09T23:34:53.804900

```local
$TTL    86400                    ; デフォルトのキャッシュ期間（秒単位）
@       IN      SOA     example.local. root.example.local. (
                            4         ; Serial        ; ゾーンファイルのバージョン番号を更新
                        604800         ; Refresh      ; セカンダリDNSがデータを更新する間隔
                         86400         ; Retry        ; セカンダリDNSが再試行する間隔
                       2419200         ; Expire       ; データが無効になるまでの期間
                         604800 )      ; Negative TTL ; クエリが失敗した場合のキャッシュ期間
        IN      NS      ns.example.local.             ; このゾーンのネームサーバ
ns      IN      A       172.19.0.3  ; DNSサーバのIPアドレス
example.local.  IN      A       172.19.0.3  ; ドメイン自身のAレコード
smtp    IN      A       172.19.0.4  ; SMTPサーバのIPアドレス
app     IN      A       172.19.0.5  ; アプリサーバのIPアドレス
client  IN      A       172.19.0.6  ; クライアントのIPアドレス


; リバースDNSエントリ
3       IN      PTR     ns.example.local.  ; ns のリバースエントリ
4       IN      PTR     smtp.example.local. ; smtp のリバースエントリ
5       IN      PTR     app.example.local.
6       IN      PTR     client.example.local.


```

### File: `bind\Dockerfile`

**Language:** 

**File Size:** 851 bytes
**Created:** 2024-12-08T15:49:58.772798
**Modified:** 2024-12-08T17:55:02.412019

```
FROM ubuntu/bind9:latest

# 必要なツールをインストール
RUN apt-get update && apt-get install -y \
    dnsutils \
    && apt-get clean

# rndc 設定を生成
RUN rndc-confgen -a -c /etc/bind/rndc.key && \
    chown bind:bind /etc/bind/rndc.key && \
    chmod 600 /etc/bind/rndc.key

# named.conf に controls セクションを追加
RUN echo 'controls { \
    inet 127.0.0.1 allow { any; } keys { "rndc-key"; }; \
};' >> /etc/bind/named.conf

# 必要な設定ファイルをコピー
COPY ./bind/named.conf /etc/bind/named.conf
COPY ./bind/db.example.local /etc/bind/db.example.local
COPY ./bind/db.19.172.in-addr.arpa /etc/bind/db.19.172.in-addr.arpa

# ディレクトリの権限を調整
RUN chown -R bind:bind /etc/bind

# デフォルトの BIND サーバー実行コマンド
CMD ["named", "-g", "-4"]

```

### File: `bind\named.conf`

**Language:** conf

**File Size:** 786 bytes
**Created:** 2024-12-06T22:20:36.676701
**Modified:** 2024-12-08T14:06:00.964918

```conf
options { 
    directory "/var/cache/bind";  // BINDがキャッシュデータを保存するディレクトリ
    listen-on { any; };           // すべてのインターフェースでDNSクエリを受け付ける
    allow-query { any; };         // すべてのクライアントからのクエリを許可する
};

zone "example.local" {
    type master;                  // このサーバがこのゾーンのマスターサーバであることを指定
    file "/etc/bind/db.example.local"; // ゾーンデータの設定ファイルを指定
};

zone "19.172.in-addr.arpa" {
    type master;                  // リバースゾーンのマスター設定
    file "/etc/bind/db.19.172.in-addr.arpa"; // リバースゾーン用のデータファイル
};

```

### File: `bind\rndc.key`

**Language:** key

**File Size:** 100 bytes
**Created:** 2024-12-08T15:47:06.149972
**Modified:** 2024-12-08T15:47:06.151009

```key
key "rndc-key" {
	algorithm hmac-sha256;
	secret "3W5wf5gQh2cXrPXCg9RpkeokDMLs84NbDRjGKWbSqrU=";
};

```

### File: `client\Dockerfile`

**Language:** 

**File Size:** 104 bytes
**Created:** 2024-12-07T09:46:59.189902
**Modified:** 2024-12-07T09:55:57.055548

```
FROM alpine:3.18
RUN apk update && apk add --no-cache bind-tools curl busybox-extras
CMD ["/bin/sh"]

```

### File: `client\test_mail.sh`

**Language:** sh

**File Size:** 113 bytes
**Created:** 2024-12-07T09:47:15.796411
**Modified:** 2024-12-07T09:47:20.197907

```sh
#!/bin/sh
# DNS解決テスト
nslookup smtp.example.local
# SMTPポートテスト
telnet smtp.example.local 25

```

### File: `etc\mailname`

**Language:** 

**File Size:** 20 bytes
**Created:** 2024-12-08T13:39:11.037933
**Modified:** 2024-12-08T13:39:20.542638

```
smtp.example.local

```

### File: `etc\nsswitch.conf`

**Language:** conf

**File Size:** 235 bytes
**Created:** 2024-12-07T22:04:27.047751
**Modified:** 2024-12-07T22:05:22.548125

```conf
passwd:         files
group:          files
shadow:         files
hosts:          files dns
networks:       files
protocols:      db files
services:       files
ethers:         files
rpc:            files
netgroup:       nis

```

### File: `etc\dovecot\dovecot.conf`

**Language:** conf

**File Size:** 378 bytes
**Created:** 2024-12-09T23:34:24.091979
**Modified:** 2024-12-09T23:34:24.091979

```conf
disable_plaintext_auth = no
listen = *
mail_location = maildir:/var/mail/%u/Maildir   # ユーザーのMAILDIRを指定

protocols = pop3

service pop3-login {
  inet_listener pop3 {
    port = 110
  }
}

passdb {
  driver = passwd-file
  args = /etc/dovecot/users
}

userdb {
  driver = passwd-file
  args = /etc/dovecot/users
}

auth_mechanisms = plain

```

### File: `etc\dovecot\users`

**Language:** 

**File Size:** 51 bytes
**Created:** 2024-12-09T23:34:24.091979
**Modified:** 2024-12-09T23:34:24.091979

```
test:{PLAIN}password:1000:1000::/var/mail/test:::

```

### File: `etc\postfix\main.cf`

**Language:** cf

**File Size:** 1007 bytes
**Created:** 2024-12-09T23:34:53.805900
**Modified:** 2024-12-10T20:57:17.993707

```cf
# サーバ設定
myhostname = smtp.example.local
mydomain = example.local
myorigin = $mydomain

# ネットワーク設定
inet_interfaces = all
mynetworks = 127.0.0.0/8 [::1]/128 172.19.0.0/16

# メールリレー制限（必須設定）
smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination

# メール配送設定
mydestination = $myhostname, localhost.$mydomain, localhost

# 仮想エイリアス設定
virtual_alias_domains = example.local
virtual_alias_maps = hash:/etc/postfix/virtual

# その他
smtpd_banner = $myhostname ESMTP $mail_name
home_mailbox = Maildir/

# デバッグ用設定
debug_peer_level = 2
debug_peer_list = 127.0.0.1
debugger_command =
    PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
    ddd $daemon_directory/$process_name $process_id & sleep 5

compatibility_level = 2

# TLSの設定
smtpd_tls_security_level = none
smtp_tls_security_level = may

# 接続タイムアウトの設定
smtpd_helo_required = yes

```

### File: `etc\postfix\master.cf`

**Language:** cf

**File Size:** 1949 bytes
**Created:** 2024-12-09T23:34:24.092974
**Modified:** 2024-12-09T23:34:24.092974

```cf
#
# Postfix master process configuration file. For details on the format
# of the file, see the master(5) manual page (command: "man 5 master").
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (yes)   (never) (100)
# ==========================================================================
smtp      inet  n       -       n       -       -       smtpd
  -o debug_peer_list=smtp.example.local
  -o debug_peer_level=3
pickup    unix  n       -       n       60      1       pickup
proxymap  unix  -       -       n       -       -       proxymap
rewrite   unix  -       -       n       -       -       trivial-rewrite
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
relay     unix  -       -       n       -       -       smtp
smtp      unix  -       -       n       -       -       smtp
retry     unix  -       -       n       -       -       error
local     unix  -       n       n       -       -       local
#
# Additional services
#
error     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
showq     unix  n       -       n       -       -       showq
```

### File: `smtp\Dockerfile`

**Language:** 

**File Size:** 2218 bytes
**Created:** 2024-12-10T20:46:37.669969
**Modified:** 2024-12-11T18:16:58.614940

```
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    postfix \
    rsyslog \
    nano \
    iproute2 \
    dnsutils \
    procps \
    tzdata \
    dovecot-pop3d \
    dovecot-core \
    bash \
    && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata \
    && apt-get clean \
    && groupadd -g 1000 syslog \
    && useradd -r -m -s /bin/false rsyslog -u 107 -g syslog

# Postfixの設定ファイルをコピー
COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf

# /etc/aliases ファイルの作成（ただし newaliases は後で実行）
RUN echo "root: postmaster" > /etc/aliases

# 必要なソケットディレクトリを作成し、所有権を設定
RUN mkdir -p /var/spool/postfix/private && \
    chown -R postfix:postfix /var/spool/postfix/private

# 仮想アドレスマップの作成
RUN mkdir -p /etc/postfix && \
    echo "recipient@example.local test" > /etc/postfix/virtual && \
    postmap /etc/postfix/virtual && \
    postconf -e "smtpd_helo_required=yes" && \
    postconf -e "virtual_alias_maps=hash:/etc/postfix/virtual"

# メールスプールディレクトリの作成
RUN mkdir -p /var/mail && \
    chmod 755 /var/mail && \
    chown postfix:postfix /var/mail

# ローカルメール用ユーザーの作成（GIDを変更）
RUN if ! getent group test > /dev/null; then groupadd -g 2000 test; fi
RUN useradd -m -s /bin/bash -d /var/mail/test test -u 2000 -g 2000
RUN if ! getent group user > /dev/null; then groupadd -g 2001 user; fi
RUN useradd -m -s /bin/bash -d /var/mail/user user -u 2001 -g 2001
RUN echo "test:password" | chpasswd
RUN echo "user:password" | chpasswd

# エイリアスマップを更新
RUN newaliases

# ログの設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf
RUN chmod 777 /proc/kmsg # /proc/kmsg へのアクセス権限を変更

# 初期化スクリプトをコピー
COPY smtp/init.sh /init.sh
RUN chmod +x /init.sh

# コンテナ起動時のコマンドを変更
CMD ["/init.sh"]
```

### File: `smtp\init.sh`

**Language:** sh

**File Size:** 561 bytes
**Created:** 2024-12-09T23:34:53.806898
**Modified:** 2024-12-11T18:16:39.203758

```sh
#!/bin/sh

# エイリアスマップを更新
echo "Updating aliases..."
newaliases

# Maildirディレクトリの作成と所有権の設定
echo "Ensuring Maildir structure..."
mkdir -p /var/mail/test/Maildir/{cur,new,tmp}
chown -R test:test /var/mail/test/Maildir
chmod -R 700 /var/mail/test/Maildir

# SetGIDビットを削除
chmod -R g-s /var/mail/test/Maildir

# rsyslog と Postfix の起動
echo "Starting rsyslog and postfix..."
service rsyslog start
postfix start-fg &

# Dovecotの起動
echo "Starting Dovecot..."
dovecot -F
```

