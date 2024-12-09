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
