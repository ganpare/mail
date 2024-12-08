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


# ローカルメール用ユーザーの作成
RUN groupadd -g 1000 test && \
    useradd -m -s /bin/bash -u 1000 -g 1000 test && \
    groupadd -g 1001 user && \
    useradd -m -s /bin/bash -u 1001 -g 1001 user

# メールスプールディレクトリとMaildir構造の作成
RUN mkdir -p /var/mail/test/Maildir/cur && \
    mkdir -p /var/mail/test/Maildir/new && \
    mkdir -p /var/mail/test/Maildir/tmp && \
    chmod -R 755 /var/mail && \
    chown -R test:test /var/mail


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

# エイリアスマップを更新
RUN newaliases

# ログの設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf

# コンテナ起動時のコマンド
CMD ["sh", "-c", "service rsyslog start && postfix start-fg"]
