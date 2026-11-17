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
    

# dnf module disable nodejs -y  &>> $TIMESTAMP
# VALIDATE "$?" "disable default nodejs"

# dnf module enable nodejs:18 -y &>> $TIMESTAMP
# VALIDATE "$?" "enable nodejs 18"

dnf install nodejs -y &>> $TIMESTAMP
VALIDATE "$?" "install nodejs 18"

id roboshop &>> $TIMESTAMP
if [ $? -ne 0 ]
then
    useradd roboshop &>> $TIMESTAMP
    VALIDATE "$?" "create roboshop user"
else
    echo -e "$Y roboshop user already exist, so skipping$N"
fi

mkdir -p /app &>> $TIMESTAMP
VALIDATE "$?" "create app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $TIMESTAMP
VALIDATE "$?" "Download the application code"

cd /app; unzip -o /tmp/catalogue.zip &>> $TIMESTAMP
VALIDATE "$?" "unzip the application code"

npm install &>> $TIMESTAMP
VALIDATE "$?" "download the dependencies"

cp /home/ec2-user/29thO26-Roboshop-Shell/catalogue.service /etc/systemd/system/catalogue.service &>> $TIMESTAMP
VALIDATE "$?" "Setup SystemD Catalogue Service"

systemctl daemon-reload; systemctl enable catalogue; systemctl start catalogue &>> $TIMESTAMP
VALIDATE "$?" "enable and start catalogue service"

cp /home/ec2-user/29thO26-Roboshop-Shell/mongodb-client.repo /etc/yum.repos.d/mongo.repo &>> $TIMESTAMP
VALIDATE "$?" "setup MongoDB repo"

dnf install mongodb-org-shell -y &>> $TIMESTAMP
VALIDATE "$?" "install mongodb-client"

mongo --host mongodb.kiranku.online </app/schema/catalogue.js &>> $TIMESTAMP
VALIDATE "$?" "Load Schema"

systemctl restart catalogue &>> $TIMESTAMP
VALIDATE "$?" "restart catalogue service"

