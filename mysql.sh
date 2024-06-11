#!/bin/bash
source ./common.sh

check_root

echo "Please enter DB password"
read -s mysql_root_pass

dnf install mysql-serverdd -y &>>$LOGFILE
#VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOGFILE
#VALIDATE $? "Enabling mysql"

systemctl start mysqld &>>$LOGFILE
#VALIDATE $? "Starting mysql"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting root password"

#Below code is useful for idempotent nature
#mysql -h db.guru97s.cloud -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE instead of using the password ExpenseApp@1 which is hard coded,we are creating a variable such as db_password which is given during running the script
mysql -h db.guru97s.cloud -uroot -p${mysql_root_pass} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ] #if exit status is 1 then we need to setup a new password,if it is 0 then password is already setup
then
    mysql_secure_installation --set-root-pass ${mysql_root_pass} &>>$LOGFILE
    #VALIDATE $? "Setting root password"
else
    echo -e "Root Password is already setup.. $Y SKPPING $N"
fi
    