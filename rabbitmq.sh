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
    

# dnf module disable mysql -y  &>> $TIMESTAMP
# VALIDATE "$?" "disable default mysql"

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $TIMESTAMP
VALIDATE "$?" "Configure YUM Repos"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $TIMESTAMP
VALIDATE "$?" "Configure YUM Repos"

dnf install rabbitmq-server -y   &>> $TIMESTAMP
VALIDATE "$?" "Install RabbitMQ"

systemctl enable rabbitmq-server ; systemctl start rabbitmq-server &>> $TIMESTAMP
VALIDATE "$?" "enable and start service"

rabbitmqctl add_user roboshop roboshop123 &>> $TIMESTAMP
VALIDATE "$?" "create user for the application."

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $TIMESTAMP
VALIDATE "$?" "set permissions"