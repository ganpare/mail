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

# Maildir ディレクトリの作成と権限設定
RUN mkdir -p /var/mail/test/Maildir/{cur,new,tmp} && \
    chown -R test:test /var/mail/test && \
    chmod -R 700 /var/mail/test

# Postfix の設定ファイルをコピー
COPY smtp_config/postfix/main.cf /etc/postfix/main.cf
COPY smtp_config/postfix/master.cf /etc/postfix/master.cf
COPY smtp_config/postfix/virtual /etc/postfix/virtual

# 仮想エイリアスマップのコンパイル
RUN postmap /etc/postfix/virtual

# /etc/aliases の設定と更新
RUN echo "postmaster: root" > /etc/aliases && \
    newaliases

# rsyslog の設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf

# rsyslog の設定を修正して imklog を無効化
RUN sed -i '/imklog/d' /etc/rsyslog.conf

# ログディレクトリと権限の設定
RUN mkdir -p /var/log/mail && \
    touch /var/log/mail/mail.log && \
    chown postfix:postfix /var/log/mail/mail.log

# Postfix と rsyslog の起動スクリプト
CMD ["sh", "-c", "service rsyslog start && postfix start-fg"]
