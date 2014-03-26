#!/bin/bash
PHP_INSTALLED=`dpkg -l| awk '{print $2}' | grep '^php5' 2>&1 > /dev/null; echo $?`
MYSQL_INSTALLED=`dpkg -l| awk '{print $2}' | grep '^mysql-server' 2>&1 > /dev/null; echo $?` 
NGINX_INSTALLED=`dpkg -l| awk '{print $2}' | grep '^php' 2>&1 > /dev/null; echo $?`
if [ $PHP_INSTALLED -ne 0 ] 
then
	echo "PHP5 installing....."
	sudo apt-get install php5 -y 2>&1 > /dev/null
fi
if [ $MYSQL_INSTALLED -ne 0 ] 
then
	echo "Mysql Server installing....."
	sudo apt-get install mysql-server -y 2>&1 > /dev/null
fi
if [ $NGINX_INSTALLED -ne 0 ] 
then
	echo "Nginx installing....."
	sudo apt-get install nginx -y 2>&1 > /dev/null
fi

echo -e "Enter Domain Name: "
read DOAMIN_NAME
echo 127.0.0.1 $DOAMIN_NAME

cd /var/www/html/
wget http://wordpress.org/latest.zip 2>&1 > /dev/null
unzip latest.zip

mysql -u root -e"create database example.com_db;"

