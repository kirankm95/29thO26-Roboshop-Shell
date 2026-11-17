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
    

cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $TIMESTAMP
VALIDATE "$?" "copy MongoDB repo file"

dnf install mongodb-org -y   &>> $TIMESTAMP
VALIDATE "$?" "Install MongoDB"

systemctl enable mongod   &>> $TIMESTAMP
VALIDATE "$?" "Enable MongoDB Service"

systemctl start mongod   &>> $TIMESTAMP
VALIDATE "$?" "start MongoDB Service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $TIMESTAMP
VALIDATE "$?" "allow remote connections"

systemctl restart mongod   &>> $TIMESTAMP
VALIDATE "$?" "restart MongoDB Service"