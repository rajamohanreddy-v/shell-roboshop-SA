#!/bin/bash
source ./common.sh

checkroot

dnf install mysql-server -y &>>"$LOGS_FILE"
Validate $? "Installing Mysql" 

systemctl enable mysqld &>>"$LOGS_FILE"
systemctl start mysqld  &>>"$LOGS_FILE"
Validate $? "starting  Mysql"

mysql -u root -pRoboShop@1 -e 'show databases;' &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
    Validate $? "Setting Root Password"
else
    echo -e "Root password already set ... $Y SKIPPING $N"
fi