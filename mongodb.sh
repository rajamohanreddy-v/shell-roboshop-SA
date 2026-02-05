#!/bin/bash

source ./common.sh

checkroot

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>"$LOGS_FILE"
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>"$LOGS_FILE"
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>>"$LOGS_FILE"
systemctl start mongod &>>"$LOGS_FILE"
VALIDATE $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>"$LOGS_FILE"
VALIDATE $? "DB now heariing on internet"

systemctl restart mongod &>>"$LOGS_FILE"
VALIDATE $? "re-starting mongod"
