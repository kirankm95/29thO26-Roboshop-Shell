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

dnf install nginx -y &>> $TIMESTAMP
VALIDATE "$?" "Install Nginx"

systemctl enable nginx; systemctl start nginx &>> $TIMESTAMP
VALIDATE "$?" "Start & Enable Nginx service"

rm -rf /usr/share/nginx/html/* &>> $TIMESTAMP
VALIDATE "$?" "Remove the default content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $TIMESTAMP
VALIDATE "$?" "Download the frontend content"

cd /usr/share/nginx/html; unzip /tmp/web.zip &>> $TIMESTAMP
VALIDATE "$?" "Extract the frontend content"

cp /home/ec2-user/29thO26-Roboshop-Shell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>> $TIMESTAMP
VALIDATE "$?" "copy Nginx Reverse Proxy Configuration"

systemctl restart nginx  &>> $TIMESTAMP
VALIDATE "$?" "Restart Nginx Service"