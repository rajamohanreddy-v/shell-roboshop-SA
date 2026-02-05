#!/bin/bash
USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPTD=$PWD
START=$(date +%s)
MONGODB="mongodb.dawsrs.online"
MYSQL="mysql.dawsrs.online"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p "$LOG_FOLDER" #Creates Logfile folder


checkroot() {      #Checks whether root user or normal user

if [ "$USER_ID" -ne 0 ]; then
    echo -e "$R Please run the script with root user $N" 
    exit 1
fi
}

VALIDATE() { if [ "$1" -ne 0 ]; then #Validates whether the commands working or not
    echo -e " "$2"...is "$R" Failed $N" | tee -a $LOGS_FILE
    exit 1
    else
    echo -e " "$2"...is "$G" Success $N" | tee -a $LOGS_FILE
    fi
}

nodejs_setup() {                                        #this for common nodejs setup
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling nodejs" 

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "enabling nodejs" 

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "installing nodejs" 

}

java_setup() {
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    cd /app 
    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Installing and Building $app_name"

    mv target/$app_name-1.0.jar $app_name.jar 
    VALIDATE $? "Moving and Renaming $app_name"

}

python_setup() {

    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Installing Python"

    cd /app 
    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup() {

    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "Roboshop user already exist ... $Y SKIPPING $N"
    fi

    mkdir -p /app &>>$LOGS_FILE
    VALIDATE $? "Creatign directory"

    curl -L -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOGS_FILE
    VALIDATE $? "downloading the code"

    rm -rf /app/* &>>$LOGS_FILE
    VALIDATE $? "Clearing the previous code"

    unzip -o /tmp/$app_name.zip &>>$LOGS_FILE
    VALIDATE $? "Uziping $app_name code"

}

service_setup() {
    cp "$SCRIPTD"/"$app_name".service /etc/systemd/system/$app_name.service
    VALIDATE $? "copying service file"

    systemctl daemon-reload
    systemctl enable "$app_name"
    systemctl start "$app_name"
    VALIDATE $? "Starting the service"
}

app_restart() {
    systemctl restart "$app_name"
    VALIDATE $? "Restarting the service"
}

nginix_setup() {

dnf module disable nginx -y &>>"$LOGS_FILE"
dnf module enable nginx:1.24 -y &>>"$LOGS_FILE"
Validate $? "enabling nginx" 

dnf install nginx -y &>>"$LOGS_FILE"
Validate $? "installing nginx" 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>"$LOGS_FILE"
Validate $? "copying code" 

rm -rf /usr/share/nginx/html/*  &>>"$LOGS_FILE"
Validate $? "removing existing code" 

cd /usr/share/nginx/html &>>"$LOGS_FILE"
unzip /tmp/frontend.zip &>>"$LOGS_FILE"
rm -rf /etc/nginx/nginx.conf &>>"$LOGS_FILE"
cp $SCRIPTD/nginx.conf /etc/nginx/nginx.conf &>>"$LOGS_FILE"
Validate $? "copying configuration"

systemctl enable nginx &>>"$LOGS_FILE"
systemctl start nginx &>>"$LOGS_FILE"
Validate $? "starting nginx"

}

golang_setup() {

dnf install golang  -y &>>"$LOGS_FILE"
Validate $? "installing golang"
cd /app &>>"$LOGS_FILE"
Validate $? "Redirecting to the app folder"
go mod init dispatch &>>"$LOGS_FILE"
go get &>>"$LOGS_FILE"
go build &>>"$LOGS_FILE"
Validate $? "installing dependencies"

}

print_total_time() {
    END=$(date +%s)
    total_time=$(($END - $START))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Script execute in: $G $total_time seconds $N" | tee -a $LOGS_FILE
}





