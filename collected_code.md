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
│   ├── dovecot/
│   │   ├── dovecot.conf
│   │   └── users
│   ├── postfix/
│   │   ├── main.cf
│   │   └── master.cf
│   ├── mailname
│   └── nsswitch.conf
<<<<<<< HEAD
├── mail/
├── pop3/
│   └── Dockerfile
=======
>>>>>>> temp-branch
├── smtp/
│   ├── Dockerfile
│   └── init.sh
├── docker-compose.yml
├── smtp_aliases
<<<<<<< HEAD
└── よく使うコマンド
=======
└── よく使うコマンド.txt
>>>>>>> temp-branch

```

### File: `docker-compose.yml`

**Language:** yml

<<<<<<< HEAD
**File Size:** 2164 bytes
**Created:** 2024-12-08T20:25:28.565683
**Modified:** 2024-12-09T06:51:55.448169
=======
**File Size:** 1739 bytes
**Created:** 2024-12-09T22:48:38.323964
**Modified:** 2024-12-09T22:48:38.324964
>>>>>>> temp-branch

```yml
version: '3.8'

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

<<<<<<< HEAD
smtp-server:
  build:
    context: ./
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
  volumes:
    - ./smtp_aliases:/etc/aliases
    - mail_data:/var/mail      # 共有ボリュームをマウント
    - ./smtp_config/postfix/main.cf:/etc/postfix/main.cf
    - ./smtp_config/postfix/master.cf:/etc/postfix/master.cf
    - ./smtp_config/postfix/virtual:/etc/postfix/virtual
  restart: always
  depends_on:
    - dns-server


  pop3-server:
    build:
      context: ./ 
      dockerfile: ./pop3/Dockerfile
    container_name: pop3-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.7
    ports:
      - "110:110"    # POP3ポート
    volumes:
      - ./etc/dovecot:/etc/dovecot
      - mail_data:/var/mail           # 共有ボリュームをマウント
      - mail_data:/var/log/dovecot    # ログも共有（オプション）
    restart: always
    depends_on:
      - smtp-server
=======
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

>>>>>>> temp-branch

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
<<<<<<< HEAD

=======
>>>>>>> temp-branch
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

<<<<<<< HEAD
### File: `よく使うコマンド`
=======
### File: `よく使うコマンド.txt`
>>>>>>> temp-branch

**Language:** txt

**File Size:** 1247 bytes
<<<<<<< HEAD
**Created:** 2024-12-08T23:51:52.936979
**Modified:** 2024-12-08T23:51:56.037352

```
=======
**Created:** 2024-12-09T21:08:27.547033
**Modified:** 2024-12-09T21:08:27.604225

```txt
>>>>>>> temp-branch
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

### File: `etc\dovecot\dovecot.conf`

**Language:** conf

**File Size:** 378 bytes
**Created:** 2024-12-07T14:17:38.497898
**Modified:** 2024-12-09T06:42:10.224698

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
**Created:** 2024-12-07T14:17:59.085351
**Modified:** 2024-12-08T23:50:35.351398

```
test:{PLAIN}password:1000:1000::/var/mail/test:::

```

### File: `etc\postfix\main.cf`

**Language:** cf

<<<<<<< HEAD
**File Size:** 1007 bytes
**Created:** 2024-12-07T11:40:37.585436
**Modified:** 2024-12-09T06:47:35.078729
=======
**File Size:** 1013 bytes
**Created:** 2024-12-09T19:46:13.023999
**Modified:** 2024-12-09T21:53:43.289921
>>>>>>> temp-branch

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

<<<<<<< HEAD
=======
# Maildir形式の設定を追加
home_mailbox = Maildir/

# Maildir形式の有効化
mailbox_command =
mailbox_transport = 


>>>>>>> temp-branch
```

### File: `etc\postfix\master.cf`

**Language:** cf

<<<<<<< HEAD
**File Size:** 1949 bytes
**Created:** 2024-12-07T22:02:14.202922
**Modified:** 2024-12-08T23:10:10.228977
=======
**File Size:** 901 bytes
**Created:** 2024-12-09T19:46:13.023999
**Modified:** 2024-12-09T19:46:13.023999
>>>>>>> temp-branch

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
<<<<<<< HEAD
#
# Additional services
#
error     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
showq     unix  n       -       n       -       -       showq
```

### File: `pop3\Dockerfile`

**Language:** 

**File Size:** 1428 bytes
**Created:** 2024-12-07T14:16:55.544774
**Modified:** 2024-12-08T23:53:18.748005

```
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    dovecot-pop3d \
    dovecot-core \
    && apt-get clean

# ローカルユーザーとグループの作成
# UIDとGIDはsmtp-serverと一致させる（ここでは1000）
RUN groupadd -g 1000 test && \
    useradd -m -s /bin/bash -u 1000 -g test test

# Dovecotの設定ファイルを適切な場所にコピー
COPY etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY etc/dovecot/users /etc/dovecot/users

# メールスプールディレクトリとMaildir構造の作成
RUN mkdir -p /var/mail/test/Maildir/{cur,new,tmp} && \
    chown -R test:test /var/mail/test && \
    chmod -R 700 /var/mail/test

# Dovecotのユーザー情報ファイルの権限を設定
RUN chmod 600 /etc/dovecot/users && \
    chown test:test /etc/dovecot/users

# Dovecotのログディレクトリを作成
RUN mkdir -p /var/log/dovecot && \
    touch /var/log/dovecot/dovecot.log && \
    chown test:test /var/log/dovecot/dovecot.log

# Dovecotのログ設定を更新（必要に応じて）
RUN echo "log_path = /var/log/dovecot/dovecot.log" >> /etc/dovecot/conf.d/10-logging.conf && \
    echo "auth_verbose = yes" >> /etc/dovecot/conf.d/10-auth.conf && \
    echo "mail_debug = yes" >> /etc/dovecot/conf.d/10-mail.conf

# デフォルトコマンド
CMD ["dovecot", "-F"]
=======
>>>>>>> temp-branch

```

### File: `smtp\Dockerfile`

**Language:** 

<<<<<<< HEAD
**File Size:** 1623 bytes
**Created:** 2024-12-07T11:17:12.979747
**Modified:** 2024-12-09T06:50:54.136784
=======
**File Size:** 2173 bytes
**Created:** 2024-12-09T19:46:13.024998
**Modified:** 2024-12-09T22:23:55.526244
>>>>>>> temp-branch

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
<<<<<<< HEAD
    telnet \
    strace \
    tree && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean
=======
    dovecot-pop3d \
    dovecot-core \
    && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata \
    && apt-get clean \
    && groupadd -g 1000 syslog \
    && useradd -r -m -s /bin/false rsyslog -u 107 -g syslog 
>>>>>>> temp-branch

# ローカルユーザーとグループの作成
RUN groupadd -g 1000 test && \
    useradd -m -s /bin/bash -u 1000 -g test -d /var/mail/test test

# Maildir ディレクトリの作成と権限設定
RUN mkdir -p /var/mail/test/Maildir/{cur,new,tmp} && \
    chown -R test:test /var/mail/test && \
    chmod -R 700 /var/mail/test

# Postfix の設定ファイルをコピー
COPY smtp_config/postfix/main.cf /etc/postfix/main.cf
COPY smtp_config/postfix/master.cf /etc/postfix/master.cf
COPY smtp_config/postfix/virtual /etc/postfix/virtual

<<<<<<< HEAD
# 仮想エイリアスマップのコンパイル
RUN postmap /etc/postfix/virtual
=======
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
>>>>>>> temp-branch

# /etc/aliases の設定と更新
RUN echo "postmaster: root" > /etc/aliases && \
    newaliases

# rsyslog の設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf
RUN chmod 777 /proc/kmsg # /proc/kmsg へのアクセス権限を変更

<<<<<<< HEAD
# rsyslog の設定を修正して imklog を無効化
RUN sed -i '/imklog/d' /etc/rsyslog.conf

# ログディレクトリと権限の設定
RUN mkdir -p /var/log/mail && \
    touch /var/log/mail/mail.log && \
    chown postfix:postfix /var/log/mail/mail.log

# Postfix と rsyslog の起動スクリプト
CMD ["sh", "-c", "service rsyslog start && postfix start-fg"]
=======
# 初期化スクリプトをコピー
COPY smtp/init.sh /init.sh
RUN chmod +x /init.sh

# コンテナ起動時のコマンドを変更
CMD ["/init.sh"]
>>>>>>> temp-branch

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

