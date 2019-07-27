#!/bin/bash

# Srtting variables

DB_ROOT_PWD='bubuntu'




echo "<<<<<<<<<<<<<<<<<<  Update system  >>>>>>>>>>>>>>>>>>>>"
sudo su
yum update -y -q

if [ $? -eq 0]; then
	echo"Packages sucsesfully updated"
else
	echo "Error updating yum/ Check logfile for more details"
	exit 1
fi

echo "<<<<<<<<<<<<<<<<<<  Install Vim  >>>>>>>>>>>>>>>>>>>>"
yum install vim -y -q
echo "<<<<<<<<<<<<<<<<<<  Install epel  >>>>>>>>>>>>>>>>>>>>"
yum install epel-release -y -q
echo "<<<<<<<<<<<<<<<<<<  rmp   >>>>>>>>>>>>>>>>>>>>"
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-7.noarch.rpm
echo "<<<<<<<<<<<<<<<<<<  Install PHP 7.2  >>>>>>>>>>>>>>>>>>>>"
yum --enablerepo=remi-php72 install php php-mysql php-xml php-soap php-xmlrpc php-mbstring php-json php-gd php-mcrypt -y -q
echo "<<<<<<<<<<<<<<<<<<  Install and enable Apache  >>>>>>>>>>>>>>>>>>>>"
yum --enablerepo=epel,remi install httpd -y -q
systemctl start httpd.service
systemctl enable httpd.service
echo "<<<<<<<<<<<<<<<<<<  Install MySQL  >>>>>>>>>>>>>>>>>>>>"
yum install mysql-server -y -q
systemctl start mysqld.service

# MySQL configuration
echo "***************** Configuring MySQL ******************"

mysql --user=root -D mysql <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${DB_ROOT_PWD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

systemctl restart mysqld.service
systemctl enable mysqld.service

echo "<<<<<<<<<<<<<<<<<<  Check version Apache, PHP, MySql  >>>>>>>>>>>>>>>>>>>>"
httpd -v
php -v
mysql -V

