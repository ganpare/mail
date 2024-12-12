FROM debian:bullseye-slim

# 必要な環境変数を設定
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

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
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Postfixの設定ファイルをコピー
COPY etc/postfix/main.cf /etc/postfix/main.cf
COPY etc/postfix/master.cf /etc/postfix/master.cf

# /etc/aliases ファイルを作成し newaliases を実行
RUN echo "root: postmaster" > /etc/aliases && newaliases

# ローカルユーザ test と user を作成
RUN useradd -m -s /usr/sbin/nologin test && \
    useradd -m -s /usr/sbin/nologin user && \
    echo "test:password" | chpasswd && \
    echo "user:password" | chpasswd

# 仮想アドレスマップの作成
RUN mkdir -p /etc/postfix && \
    echo "recipient@example.local test" > /etc/postfix/virtual && \
    echo "test@example.local test" >> /etc/postfix/virtual && \
    postmap /etc/postfix/virtual

# Postfixの設定を追加
RUN postconf -e "smtpd_helo_required=yes" && \
    postconf -e "virtual_alias_maps=hash:/etc/postfix/virtual"

# メールスプールディレクトリの作成と権限設定
RUN mkdir -p /var/mail && \
    chmod 755 /var/mail && \
    chown postfix:postfix /var/mail

# rsyslogのログ設定
RUN echo "*.* /var/log/mail.log" > /etc/rsyslog.d/50-default.conf && \
    chmod 666 /proc/kmsg

# 初期化スクリプトをコピー
COPY smtp/init.sh /init.sh
RUN chmod +x /init.sh

# コンテナ起動時のコマンドを設定
CMD ["/init.sh"]
