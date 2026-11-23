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

dnf install maven -y &>> $TIMESTAMP
VALIDATE "$?" "install maven"

id roboshop &>> $TIMESTAMP
if [ $? -ne 0 ]
then
    useradd roboshop &>> $TIMESTAMP
    VALIDATE "$?" "create roboshop user"
else
    echo -e "$Y roboshop user already exist, so skipping$N"
fi

mkdir /app &>> $TIMESTAMP
VALIDATE "$?" "setup an app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $TIMESTAMP
VALIDATE "$?" "Download the application code"

cd /app; unzip /tmp/shipping.zip &>> $TIMESTAMP
VALIDATE "$?" "unzip code"

mvn clean package &>> $TIMESTAMP
VALIDATE "$?" "download the dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $TIMESTAMP
VALIDATE "$?" "rename file name"

cp /home/ec2-user/29thO26-Roboshop-Shell/shipping.service /etc/systemd/system/shipping.service &>> $TIMESTAMP
VALIDATE "$?" "Setup SystemD Shipping Service"

systemctl daemon-reload; systemctl enable shipping ; systemctl start shipping &>> $TIMESTAMP
VALIDATE "$?" "start the service"

dnf install mysql -y &>> $TIMESTAMP
VALIDATE "$?" "install mysql client"

mysql -h mysql.kiranku.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $TIMESTAMP
VALIDATE "$?" "Load Schema"

systemctl restart shipping &>> $TIMESTAMP
VALIDATE "$?" "restart shipping service"