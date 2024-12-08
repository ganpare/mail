#!/bin/sh
# DNS解決テスト
nslookup smtp.example.local
# SMTPポートテスト
telnet smtp.example.local 25
