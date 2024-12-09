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
├── dovecot/
│   ├── dovecot.conf
│   └── users
├── etc/
│   ├── postfix/
│   │   ├── main.cf
│   │   └── master.cf
│   ├── mailname
│   └── nsswitch.conf
├── smtp/
│   ├── Dockerfile
│   └── init.sh
├── docker-compose.yml
├── smtp_aliases
└── よく使うコマンド.txt

```

### File: `docker-compose.yml`

**Language:** yml

**File Size:** 1739 bytes
**Created:** 2024-12-09T22:48:38.323964
**Modified:** 2024-12-09T22:48:38.324964

```yml
services:
  dns-server:
    build:
      context: ./  # ルートディレクトリをコンテキストに設定
      dockerfile: ./bind/Dockerfile  # Dockerfileの場所を明示的に指定
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
      - ./dovecot:/etc/dovecot  # Dovecot設定ファイル追加
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

### File: `smtp_aliases`

**Language:** 

**File Size:** 36 bytes
**Created:** 2024-12-08T19:25:26.867989
**Modified:** 2024-12-09T20:26:32.703783

```
postmaster:    root
recipient: user
```

### File: `よく使うコマンド.txt`

**Language:** txt

**File Size:** 1247 bytes
**Created:** 2024-12-09T21:08:27.547033
**Modified:** 2024-12-09T21:08:27.604225

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

**File Size:** 883 bytes
**Created:** 2024-12-07T09:44:20.362875
**Modified:** 2024-12-08T14:11:22.240700

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
to_email = "recipient@example.local"
subject = "Test Mail from App Server"
body = "This is a test email sent from app-server via dockerized SMTP server."

# メールフォーマット
message = f"Subject: {subject}\n\n{body}"

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
**Created:** 2024-12-08T14:06:27.894878
**Modified:** 2024-12-09T21:03:02.330842

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
**Created:** 2024-12-06T22:23:27.786121
**Modified:** 2024-12-09T21:03:12.388028

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

### File: `dovecot\dovecot.conf`

**Language:** conf

**File Size:** 588 bytes
**Created:** 2024-12-09T19:46:13.023999
**Modified:** 2024-12-09T22:42:51.362552

```conf
disable_plaintext_auth = no   # 平文認証を許可（テスト用）
listen = *                   # 全てのインターフェースでリッスン
mail_location = maildir:/var/mail/%u/Maildir


protocols = pop3             # POP3プロトコルを有効化

service pop3-login {
  inet_listener pop3 {
    port = 110               # POP3のデフォルトポート
  }
}

passdb {
  driver = passwd-file       # ユーザー認証にファイルを使用
  args = /etc/dovecot/users
}

userdb {
  driver = passwd
}

auth_mechanisms = plain      # 認証方式

```

### File: `dovecot\users`

**Language:** 

**File Size:** 122 bytes
**Created:** 2024-12-09T19:46:13.024998
**Modified:** 2024-12-09T22:08:43.694541

```
test:{PLAIN}password:2000:2000::/var/mail/test::userdb_mail
user:{PLAIN}password:2001:2001::/var/mail/user::userdb_mail

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

### File: `etc\postfix\main.cf`

**Language:** cf

**File Size:** 1013 bytes
**Created:** 2024-12-09T19:46:13.023999
**Modified:** 2024-12-09T21:53:43.289921

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
mydestination = $myhostname, localhost.$mydomain, localhost, example.local

# その他
smtpd_banner = $myhostname ESMTP $mail_name

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

# Maildir形式の設定を追加
home_mailbox = Maildir/

# Maildir形式の有効化
mailbox_command =
mailbox_transport = 


```

### File: `etc\postfix\master.cf`

**Language:** cf

**File Size:** 901 bytes
**Created:** 2024-12-09T19:46:13.023999
**Modified:** 2024-12-09T19:46:13.023999

```cf
smtp      inet  n       -       n       -       -       smtpd
  -o debug_peer_list=smtp.example.local
  -o debug_peer_level=3
proxymap  unix  -       -       n       -       -       proxymap
rewrite   unix  -       -       n       -       -       trivial-rewrite
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
relay     unix  -       -       n       -       -       smtp
smtp      unix  -       -       n       -       -       smtp
retry     unix  -       -       n       -       -       error
local     unix  -       n       n       -       -       local

```

### File: `smtp\Dockerfile`

**Language:** 

**File Size:** 2173 bytes
**Created:** 2024-12-09T19:46:13.024998
**Modified:** 2024-12-09T22:23:55.526244

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
RUN useradd -m -s /bin/bash test -u 2000 -g 2000
RUN if ! getent group user > /dev/null; then groupadd -g 2001 user; fi
RUN useradd -m -s /bin/bash user -u 2001 -g 2001
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

**File Size:** 542 bytes
**Created:** 2024-12-08T13:25:54.924092
**Modified:** 2024-12-09T22:30:42.912404

```sh
#!/bin/bash

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

