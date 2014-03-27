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

sudo apt-get install php5-fpm php5-mysql -y 2>&1 > /dev/null
echo "Restarting services again..."
/etc/init.d/apache2 stop 2>&1 > /dev/null
/etc/init.d/nginx restart 2>&1 > /dev/null
/etc/init.d/mysql restart 2>&1 > /dev/null
/etc/init.d/php5-fpm restart 2>&1 > /dev/null
echo -e "Enter Domain Name: "
read DOAMIN_NAME
echo "127.0.0.1 $DOAMIN_NAME" >> /etc/hosts

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
}" >> /etc/nginx/sites-enabled/$DOAMIN_NAME

cd /var/www
wget http://wordpress.org/latest.zip 2>&1 > /dev/null
unzip latest.zip

mysql -u root -e"create database examplecom_db;"
rm -f /var/www/latest.zip
cd /var/www/wordpress

chown www-data /var/www/wordpress/ -R
chmod 755 /var/www

cp wp-config-sample.php wp-config.php
sed 's/database_name_here/examplecom_db/g' -i wp-config.php
sed 's/username_here/root/g' -i wp-config.php
sed 's/password_here//g' -i wp-config.php

echo "Restarting services again..."
/etc/init.d/apache2 stop 2>&1 > /dev/null
/etc/init.d/nginx restart 2>&1 > /dev/null
/etc/init.d/mysql restart 2>&1 > /dev/null
/etc/init.d/php5-fpm restart 2>&1 > /dev/null

echo "Your wordpress server is ready.
Please open below URL in your browser:
http://$DOAMIN_NAME/"
