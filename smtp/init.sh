#!/bin/sh
echo "Test script is running!"

# ファイル確認
ls -l /var/mail
ls -l /etc/postfix
ls -l /etc/dovecot

# Postfixの確認と起動
echo "Checking Postfix configuration..."
postfix check
echo "Starting Postfix..."
postfix start

# Dovecotの起動
echo "Starting Dovecot..."
exec dovecot -F
