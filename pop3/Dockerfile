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
