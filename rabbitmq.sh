#!/bin/bash

source ./common.sh

app_name="rabbitmq"

cp "$SCRIPTD"/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>"$LOGS_FILE"
Validate $? "Copying the repos"

dnf install rabbitmq-server -y &>>"$LOGS_FILE"
Validate $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl start rabbitmq-server &>>"$LOGS_FILE"

rabbitmqctl list_users | grep -w "roboshop" &>>"$LOGS_FILE"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>>"$LOGS_FILE"
    Validate $? "Creating roboshop user"
else
    echo -e "Roboshop user already exists ... $Y SKIPPING $N"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>"$LOGS_FILE"
Validate $? "setting permissions"

systemctl enable rabbitmq-server &>>"$LOGS_FILE"
systemctl restart rabbitmq-server &>>"$LOGS_FILE"
Validate $? "starting rabbitmq"
