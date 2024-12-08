# Code Collection Report

## Directory Structure:
```
├── app-server/
│   ├── Dockerfile
│   └── send_mail.py
├── bind/
│   ├── db.example.local
│   └── named.conf
├── client/
│   ├── Dockerfile
│   └── test_mail.sh
├── etc/
│   ├── postfix/
│   │   ├── main.cf
│   │   └── master.cf
│   └── nsswitch.conf
├── mail/
├── pop3/
│   ├── dovecot/
│   │   ├── dovecot.conf
│   │   └── users
│   └── Dockerfile
├── smtp/
│   └── Dockerfile
└── docker-compose.yml

```

### File: `docker-compose.yml`

**Language:** yml

**File Size:** 1717 bytes
**Created:** 2024-12-06T22:18:49.522469
**Modified:** 2024-12-08T00:31:16.684207

```yml
services:
  dns-server:
    image: ubuntu/bind9
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
      context: ./  # ビルドのコンテキストをルートディレクトリに設定
      dockerfile: ./smtp/Dockerfile  # SMTPサーバー用Dockerfileを明示的に指定
    container_name: smtp-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.4
    environment:
      MAILNAME: smtp.example.local
    ports:
      - "1025:25"
    restart: always


  pop3-server:
    build:
      context: ./pop3
    container_name: pop3-server
    networks:
      mail_network:
        ipv4_address: 172.19.0.7
    ports:
      - "110:110"    # POP3ポート
    volumes:
      - ./pop3/dovecot:/etc/dovecot
      - ./mail:/var/mail
    restart: always
    depends_on:
      - smtp-server
      
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

**File Size:** 855 bytes
**Created:** 2024-12-07T09:44:20.362875
**Modified:** 2024-12-08T09:41:10.544306

```py
import smtplib
import os

# デバッグ用ログ
print("Starting send_mail.py execution...")

# SMTPサーバー情報
smtp_server = os.environ.get('SMTP_SERVER', 'smtp.example.local')
smtp_port = 25
print(f"SMTP Server: {smtp_server}, Port: {smtp_port}")

# メール情報
from_email = 'test@example.local'
to_email = 'user@example.local'
subject = 'Test Mail'
body = 'This is a test mail sent from app-server via dockerized smtp.'
msg = f"Subject: {subject}\n\n{body}"

# メール送信
try:
    print("Connecting to SMTP server...")
    with smtplib.SMTP(smtp_server, smtp_port, timeout=10) as server:
        print("Connection successful!")
        print("Sending email...")
        server.sendmail(from_email, [to_email], msg)
    print("Email sent successfully")
except Exception as e:
    print("Error occurred:", e)

```

### File: `bind\db.example.local`

**Language:** local

**File Size:** 1130 bytes
**Created:** 2024-12-06T22:23:27.786121
**Modified:** 2024-12-07T14:30:07.239845

```local
$TTL    86400                    ; デフォルトのキャッシュ期間（秒単位）
@       IN      SOA     example.local. root.example.local. (
                            2         ; Serial        ; ゾーンファイルのバージョン番号
                        604800         ; Refresh      ; セカンダリDNSがデータを更新する間隔
                         86400         ; Retry        ; セカンダリDNSが再試行する間隔
                       2419200         ; Expire       ; データが無効になるまでの期間
                         604800 )      ; Negative TTL ; クエリが失敗した場合のキャッシュ期間
        IN      NS      ns.example.local.             ; このゾーンのネームサーバ
ns      IN      A       172.19.0.3  ; DNSサーバのIPアドレス
smtp    IN      A       172.19.0.4  ; SMTPサーバのIPアドレス
app     IN      A       172.19.0.5  ; アプリサーバのIPアドレス
client  IN      A       172.19.0.6  ; クライアントのIPアドレス
pop3    IN      A       172.19.0.7  ; POP3サーバのIPアドレス

```

### File: `bind\named.conf`

**Language:** conf

**File Size:** 571 bytes
**Created:** 2024-12-06T22:20:36.676701
**Modified:** 2024-12-07T14:11:52.237455

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

**File Size:** 895 bytes
**Created:** 2024-12-07T11:40:37.585436
**Modified:** 2024-12-08T08:23:04.297040

```cf
# サーバ設定
myhostname = smtp.example.local
mydomain = example.local
myorigin = $mydomain

# ネットワーク設定
inet_interfaces = localhost, 172.19.0.4
mynetworks = 127.0.0.0/8 [::1]/128 172.19.0.0/16

# メールリレー制限（必須設定）
smtpd_relay_restrictions = permit_mynetworks, reject_unauth_destination

# メール配送設定
mydestination = $myhostname, localhost.$mydomain, localhost
relayhost =

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

```

### File: `etc\postfix\master.cf`

**Language:** cf

**File Size:** 129 bytes
**Created:** 2024-12-07T22:02:14.202922
**Modified:** 2024-12-08T08:09:25.213259

```cf
smtp      inet  n       -       y       -       -       smtpd
  -o debug_peer_list=smtp.example.local
  -o debug_peer_level=3

```

### File: `pop3\Dockerfile`

**Language:** 

**File Size:** 496 bytes
**Created:** 2024-12-07T14:16:55.544774
**Modified:** 2024-12-07T14:17:00.944796

```
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    dovecot-pop3d \
    dovecot-core \
    && apt-get clean

# Dovecotの設定ファイルをコピー
COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf

# メールスプールディレクトリを作成
RUN mkdir -p /var/mail && \
    chmod -R 755 /var/mail && \
    chown -R dovecot:dovecot /var/mail

# デフォルトコマンド
CMD ["dovecot", "-F"]

```

### File: `pop3\dovecot\dovecot.conf`

**Language:** conf

**File Size:** 619 bytes
**Created:** 2024-12-07T14:17:38.497898
**Modified:** 2024-12-07T14:17:43.729303

```conf
disable_plaintext_auth = no   # 平文認証を許可（テスト用）
listen = *                   # 全てのインターフェースでリッスン
mail_location = mbox:/var/mail/%u   # 各ユーザーのメールスプール

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

### File: `pop3\dovecot\users`

**Language:** 

**File Size:** 61 bytes
**Created:** 2024-12-07T14:17:59.085351
**Modified:** 2024-12-07T14:18:05.981058

```
user:{PLAIN}password:1000:1000::/var/mail/user::userdb_mail

```

### File: `smtp\Dockerfile`

**Language:** 

**File Size:** 848 bytes
**Created:** 2024-12-07T11:17:12.979747
**Modified:** 2024-12-08T08:50:38.246704

```
FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    postfix \
    rsyslog \
    iproute2 \
    dnsutils \
    procps \
    tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

# Postfixの設定ファイルをコピー
COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf

# ログの設定 (rsyslogの設定ファイルを /etc/rsyslog.d/ 配下に配置)
RUN echo "*.* /var/log/postfix.log" > /etc/rsyslog.d/50-default.conf
RUN echo "$ModLoad imuxsock" > /etc/rsyslog.d/01-no-imklog.conf  # imklogを読み込まないようにする

# コンテナ実行時のコマンド
CMD service rsyslog start && postfix start-fg
```

