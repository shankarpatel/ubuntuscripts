#!/bin/bash
PHP_INSTALLED=`dpkg -l| awk '{print $2}' | grep '^php5'  > /dev/null 2>&1; echo $?`
MYSQL_INSTALLED=`dpkg -l| awk '{print $2}' | grep '^mysql-server'  > /dev/null 2>&1; echo $?`
NGINX_INSTALLED=`dpkg -l| awk '{print $2}' | grep '^php'  > /dev/null 2>&1; echo $?`
if [ $PHP_INSTALLED -ne 0 ]
then
        echo "PHP5 installing....."
        sudo apt-get install php5 -y  > /dev/null 2>&1
fi
if [ $MYSQL_INSTALLED -ne 0 ]
then
        echo "Mysql Server installing....."
        sudo apt-get install mysql-server -y  > /dev/null 2>&1
fi
if [ $NGINX_INSTALLED -ne 0 ]
then
        echo "Nginx installing....."
        sudo apt-get install nginx -y  > /dev/null 2>&1
fi

sudo apt-get install php5-fpm php5-mysql -y  > /dev/null 2>&1
echo "Restarting services..."
/etc/init.d/apache2 stop  > /dev/null 2>&1
/etc/init.d/nginx restart  > /dev/null 2>&1
/etc/init.d/mysql restart  > /dev/null 2>&1
/etc/init.d/php5-fpm restart  > /dev/null 2>&1
echo -e "Enter Domain Name: "
read DOMAIN_NAME
echo "127.0.0.1 $DOMAIN_NAME" >> /etc/hosts

echo "server {
    listen          80 ;
    root            /var/www/wordpress;
    index           index.php index.htm index.html;
    server_name     effoneems.com;
    location ~\.php$
    {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}" >> /etc/nginx/sites-enabled/$DOMAIN_NAME

cd /var/www
wget http://wordpress.org/latest.zip  > /dev/null 2>&1
unzip latest.zip  > /dev/null 2>&1 && rm -f latest.zip

DB_NAME=`echo $DOMAIN_NAME | sed 's/\.//g'`
mysql -u root -e"create database $DB_NAME;"
cd /var/www/wordpress

chown www-data /var/www/wordpress/ -R
chmod 755 /var/www
cp wp-config-sample.php wp-config.php
sed "s/database_name_here/$DB_NAME/g" -i wp-config.php
sed "s/username_here/root/g" -i wp-config.php
sed "s/password_here//g" -i wp-config.php

echo "Restarting services again..."
/etc/init.d/apache2 stop  > /dev/null 2>&1
/etc/init.d/nginx restart  > /dev/null 2>&1
nginx_reload=$?
/etc/init.d/mysql restart  > /dev/null 2>&1
mysql_reload=$?
/etc/init.d/php5-fpm restart  > /dev/null 2>&1 
php5fpm_reload=$?

if [ $nginx_reload -eq 0 ] && [ $mysql_reload -eq 0 ] && [ $php5fpm_reload -eq 0 ]
then
	echo -e "Your wordpress server is ready.\nPlease open below URL in your browser:\nhttp://$DOMAIN_NAME/"
fi

