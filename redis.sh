#!/bin/bash
source ./common.sh
app_name="redis"

dnf module disable redis -y &>>"$LOGS_FILE"
dnf module enable redis:7 -y &>>"$LOGS_FILE"
VALIDATE $? "enabling redis"

dnf install redis -y &>>"$LOGS_FILE"
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>"$LOGS_FILE"
VALIDATE $? "redis now heariing on internet"

sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>>"$LOGS_FILE"
VALIDATE $? "disabling protect mode"

systemctl enable redis &>>"$LOGS_FILE"
systemctl restart redis &>>"$LOGS_FILE"
VALIDATE $? "redis starting"

