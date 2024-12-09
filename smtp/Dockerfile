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

# 仮想エイリアスマップのコンパイル
RUN postmap /etc/postfix/virtual

# /etc/aliases の設定と更新
RUN echo "postmaster: root" > /etc/aliases && \
    newaliases

<<<<<<< HEAD
# rsyslog の設定
=======
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
>>>>>>> temp-branch
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
