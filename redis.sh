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
    

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y  &>> $TIMESTAMP
VALIDATE "$?" "setup redis repo file"

dnf module enable redis:remi-6.2 -y &>> $TIMESTAMP
VALIDATE "$?" "Enable Redis 6.2"

dnf install redis -y &>> $TIMESTAMP
VALIDATE "$?" "install redis"

dnf install redis -y &>> $TIMESTAMP
VALIDATE "$?" "install redis"

sed -i 's/127.0.0.1/0.0.0./g' /etc/redis.conf &>> $TIMESTAMP
VALIDATE "$?" "enable remote connections"

systemctl enable redis; systemctl start redis
VALIDATE "$?" "enable and start redis"


