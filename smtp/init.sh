#!/bin/bash

# エイリアスマップを更新
echo "Updating aliases..."
newaliases

# Maildirディレクトリの作成と所有権の設定
echo "Ensuring Maildir structure..."
mkdir -p /var/mail/test/Maildir/{cur,new,tmp}
chown -R test:test /var/mail/test/Maildir
chmod -R 700 /var/mail/test/Maildir

# SetGIDビットを削除
chmod -R g-s /var/mail/test/Maildir

# rsyslog と Postfix の起動
echo "Starting rsyslog and postfix..."
service rsyslog start
postfix start-fg &

# Dovecotの起動
echo "Starting Dovecot..."
dovecot -F
