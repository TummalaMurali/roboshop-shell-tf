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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

VALIDATE $? "Setting up NPM Source"

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS"

# once the user gets created, if you run this script 2nd time
# this command will definitely fail
# IMPROVEMENT: first check the user already exist or not, then create
useradd roboshop &>>$LOGFILE

# write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "Downloading user artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/user.zip &>>$LOGFILE

VALIDATE $? "Unzipping user"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of user.service because we are inside /app
cp /home/centos/roboshop-shell-tf/user.service /etc/systemd/system/user.service

VALIDATE $? "Copying user.service"

systemctl daemon-reload

VALIDATE $? "daemon-reload"

systemctl enable user

VALIDATE $? "Enabling user"

systemctl start user

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell-tf/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "Copying mongo repo"

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongo client"

mongo --host mongodb.tmcdevops.online </app/schema/user.js &>>$LOGFILE

VALIDATE $? "loading user data into mongodb"