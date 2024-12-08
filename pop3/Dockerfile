FROM debian:bullseye-slim

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    dovecot-pop3d \
    dovecot-core \
    && apt-get clean

# Dovecotの設定ファイルを適切な場所にコピー
COPY etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY etc/dovecot/users /etc/dovecot/users

# メールスプールディレクトリを作成
RUN mkdir -p /var/mail && \
    chmod -R 755 /var/mail && \
    chown -R dovecot:dovecot /var/mail

# Dovecotのユーザー情報ファイルの権限を設定
RUN chmod 600 /etc/dovecot/users && \
    chown dovecot:dovecot /etc/dovecot/users

# デフォルトコマンド
CMD ["dovecot", "-F"]
