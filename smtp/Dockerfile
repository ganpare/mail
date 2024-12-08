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
    telnet \
    strace \
    tree && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

# ローカルユーザーとグループの作成
RUN groupadd -g 1000 test && \
    useradd -m -s /bin/bash -u 1000 -g test -d /var/mail/test test

# メールスプールディレクトリとMaildir構造の作成
RUN mkdir -p /var/mail/test/Maildir/{cur,new,tmp} && \
    chown -R test:test /var/mail/test && \
    chmod -R 700 /var/mail/test

# Postfixの設定ファイルをコピー
COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf

# 仮想アドレスマップの作成
RUN mkdir -p /etc/postfix && \
    echo "recipient@example.local test" > /etc/postfix/virtual && \
    postmap /etc/postfix/virtual && \
    postconf -e "virtual_alias_maps=hash:/etc/postfix/virtual" && \
    postconf -e "smtpd_helo_required=yes"

# /etc/aliases ファイルの作成
RUN echo "postmaster: root" > /etc/aliases && \
    newaliases

# ログの設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf

# ログディレクトリの作成と権限設定
RUN mkdir -p /var/log/mail && \
    touch /var/log/mail/mail.log && \
    chown postfix:postfix /var/log/mail/mail.log

# Postfixの起動スクリプトを設定
CMD ["sh", "-c", "service rsyslog start && postfix start-fg"]
