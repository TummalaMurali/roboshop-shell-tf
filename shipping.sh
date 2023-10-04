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

yum install maven -y &>>$LOGFILE

VALIDATE $? "Installing Maven"

useradd roboshop &>>$LOGFILE

VALIDATE $? "Installing Maven"

mkdir /app &>>$LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE

VALIDATE $? "Downloadin shipping artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving to app directory"

unzip /tmp/shipping.zip &>>$LOGFILE

VALIDATE $? "Unzipping shipping"

mvn clean package &>>$LOGFILE

VALIDATE $? "Packagin shipping app"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE

VALIDATE $? "Renaming shipping jar"

cp /home/centos/roboshop-shell-tf/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE

VALIDATE $? "Copying shipping service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable shipping &>>$LOGFILE

VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOGFILE

VALIDATE $? "Starting shipping"

yum install mysql -y &>>$LOGFILE

VALIDATE $? "Installing MySQL clien"

mysql -h mysql.tmcdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE

VALIDATE $? "Loading countries and cities info"

systemctl restart shipping &>>$LOGFILE

VALIDATE $? "Re-starting shipping"