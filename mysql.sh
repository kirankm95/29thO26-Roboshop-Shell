#!/bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "$0 started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
if [ $1 -eq 0 ]
then
    echo -e "$2 is $G success $N"
else
    echo -e "$2 $R is failed $N, got errors"
     exit 1
fi
}

 if [ $ID -ne 0 ]
 then
    echo -e "$R you are not root user, please try with root user, exiting $N"
    exit 1
 else
    echo -e "$G you are root user, going further with installation $N"
fi
    

dnf module disable mysql -y  &>> $TIMESTAMP
VALIDATE "$?" "disable default mysql"

cp /home/ec2-user/29thO26-Roboshop-Shell/mysql.repo /etc/yum.repos.d/mysql.repo  &>> $TIMESTAMP
VALIDATE "$?" "Setup the MySQL5.7 repo file"

dnf install mysql-community-server -y &>> $TIMESTAMP
VALIDATE "$?" "Install MySQL Server"

systemctl enable mysqld; systemctl start mysqld &>> $TIMESTAMP
VALIDATE "$?" "enable and Start MySQL Service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $TIMESTAMP
VALIDATE "$?" "change the default root password"

mysql -uroot -pRoboShop@1 &>> $TIMESTAMP
VALIDATE "$?" "check the new password working or not"


