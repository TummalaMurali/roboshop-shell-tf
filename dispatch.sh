#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
#/home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo "$R ERROR: Please run this script with root access"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install golang -y &>>$LOGFILE

VALIDATE $? "Installing golang"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
cd /app &>>$LOGFILE
unzip /tmp/dispatch.zip &>>$LOGFILE

VALIDATE $? "Downloading artifact, moving to app directory and Unzipping dispatch"

go mod init dispatch &>>$LOGFILE
go get 
go build &>>$LOGFILE

VALIDATE $? "Downloading dependencies and building the software"

cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE

VALIDATE $? "Copying dispatch service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE "daemon-reload"

systemctl enable dispatch &>>$LOGFILE

VALIDATE "Enabling dispatch"

systemctl start dispatch &>>$LOGFILE

VALIDATE "Starting dispatch"
