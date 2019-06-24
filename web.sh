#!/bin/bash
apt-get update 
apt-get install mysql-client php7.2 php7.2-mysql libapache2-mod-php7.2 php7.2-cli php7.2-cgi php7.2-gd apache2 apache2-utils -y 
systemctl enable apache2 
systemctl start apache2
sudo apt install curl -y
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
cd /tmp
wget -c http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
rsync -av wordpress/* /var/www/html/
chmod -R 755 /var/www/html/
cd /var/www/html
mv wp-config-sample.php wp-config.php

sed -i 's/database_name_here/wordpress/g' wp-config.php
sed -i 's/username_here/admin/g' wp-config.php
sed -i 's/password_here/wordpress/g' wp-config.php
sed -i "s/localhost/$IP_PRIVATE_BD/g" wp-config.php
IP="$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"
#echo $IP
wp core install --url=http://$IP --title=Blog\ Cozinha --admin_user=admin --admin_password=123456 --admin_email=teste@teste.com.br

systemctl restart apache2.service
rm -rf /var/www/html/index.html
sed -i '/warn/a <Directory /var/www/html/>\n   AllowOverride All\n</Directory>' /etc/apache2/sites-available/000-default.conf
a2enmod rewrite
service apache2 restart
touch /var/www/html/.htaccess
chown :www-data /var/www/html/.htaccess
chmod 664 /var/www/html/.htaccess
service apache2 restart