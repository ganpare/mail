#!/bin/sh
echo "Test script is running!"

# rsyslog の起動 (フォアグラウンドでなくデーモン化する場合は単に rsyslogd でOK)
rsyslogd

# ファイル確認
ls -l /var/mail
ls -l /etc/postfix
ls -l /etc/dovecot

# Postfixの確認と起動
echo "Checking Postfix configuration..."
postfix check
echo "Starting Postfix..."
postfix start

# Dovecotの起動（-Fオプションでフォアグラウンド実行）
echo "Starting Dovecot..."
exec dovecot -F
