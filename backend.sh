#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB password"
read -s mysql_root_pass

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enablinng nodjes version 20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

#useradd expense &>>$LOGFILE
#VALIDATE $? "Adding user expense"

#use the below code for idempotent nature in script

id expense &>>$LOGFILE # this is used for checking whether the expense user is created or not,and analysing the exit status
if [ $? -ne 0 ] #if the exit status is 1,then we need create expense user,if the exit status is 0 then expense user is already created skipping
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Adding user expense"
else
    echo -e "User is already created.. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading the web content to the app directory"

cd /app
rm -rf /app/* #Removing previous content and adding new content
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzipping code which is stored in tmp directory"

npm install &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

cp /home/ec2-user/Expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE # copying the backend.service from home direct to etc direct because shell can't able to handle VIM services
VALIDATE $? "Copying backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql client "

mysql -h db.guru97s.cloud -uroot -p${mysql_root_pass} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend"