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
