#!/bin/bash
echo "<<<<<<<<<<<<<<<<<<  Update system  >>>>>>>>>>>>>>>>>>>>"
sudo su
yum update -y
echo "<<<<<<<<<<<<<<<<<<  Install Vim  >>>>>>>>>>>>>>>>>>>>"
yum install vim -y
echo "<<<<<<<<<<<<<<<<<<  Install epel  >>>>>>>>>>>>>>>>>>>>"
yum install epel-release -y
echo "<<<<<<<<<<<<<<<<<<  rmp   >>>>>>>>>>>>>>>>>>>>"
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-7.noarch.rpm
echo "<<<<<<<<<<<<<<<<<<  Install PHP 7.2  >>>>>>>>>>>>>>>>>>>>"
yum --enablerepo=remi-php72 install php -y
yum --enablerepo=remi-php72 install php-mysql php-xml \
php-soap php-xmlrpc php-mbstring php-json php-gd php-mcrypt -y
echo "<<<<<<<<<<<<<<<<<<  Install and enable Apache  >>>>>>>>>>>>>>>>>>>>"
yum --enablerepo=epel,remi install httpd -y
systemctl start httpd.service
systemctl enable httpd.service
echo "<<<<<<<<<<<<<<<<<<  Install MySQL  >>>>>>>>>>>>>>>>>>>>"
yum install mysql-server -y 
systemctl start mysqld.service
mysql_secure_installation <<EOF

y
bubuntu
bubuntu
y
y
y
y
EOF
systemctl restart mysqld.service
systemctl enable mysqld.service
echo "Get acces on port 80, 443"
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload
echo "<<<<<<<<<<<<<<<<<<  Check version Apache, PHP, MySql  >>>>>>>>>>>>>>>>>>>>"
httpd -v
php -v
mysql -V

