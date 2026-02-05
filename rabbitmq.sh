#!/bin/bash

source ./common.sh

app_name="rabbitmq"

cp "$SCRIPTD"/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>"$LOGS_FILE"
VALIDATE $? "Copying the repos"

dnf install rabbitmq-server -y &>>"$LOGS_FILE"
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl start rabbitmq-server &>>"$LOGS_FILE"

rabbitmqctl list_users | grep -w "roboshop" &>>"$LOGS_FILE"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>"$LOGS_FILE"
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already exists ... $Y SKIPPING $N"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>"$LOGS_FILE"
VALIDATE $? "setting permissions"

systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl restart rabbitmq-server &>>"$LOGS_FILE"
VALIDATE $? "starting rabbitmq"
