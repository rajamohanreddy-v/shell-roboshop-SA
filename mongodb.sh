#!/bin/bash

source ./common.sh

checkroot

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>"$LOGS_FILE"
Validate $? "Copying mongo repo"

dnf install mongodb-org -y &>>"$LOGS_FILE"
Validate $? "Installing mongodb"

systemctl enable mongod &>>"$LOGS_FILE"
systemctl start mongod &>>"$LOGS_FILE"
Validate $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>"$LOGS_FILE"
Validate $? "DB now heariing on internet"

systemctl restart mongod &>>"$LOGS_FILE"
Validate $? "re-starting mongod"
