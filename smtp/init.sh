#!/bin/bash

# エイリアスマップを更新
echo "Updating aliases..."
newaliases

# rsyslog と Postfix の起動
echo "Starting rsyslog and postfix..."
service rsyslog start
postfix start-fg
