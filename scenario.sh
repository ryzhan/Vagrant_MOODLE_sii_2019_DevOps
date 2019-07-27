#!/bin/bash


# Setting variables

DB_ROOT_PWD='bubuntu'

echo "<<<<<<<<<<<<<<<<<< Update system >>>>>>>>>>>>>>>>>>>>"
yum update -y
echo "<<<<<<<<<<<<<<<<<< Install Vim >>>>>>>>>>>>>>>>>>>>"
yum install vim -y
echo "<<<<<<<<<<<<<<<<<< Install epel >>>>>>>>>>>>>>>>>>>>"
yum install epel-release -y
echo "<<<<<<<<<<<<<<<<<< rmp  >>>>>>>>>>>>>>>>>>>>"
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-7.noarch.rpm
echo "<<<<<<<<<<<<<<<<<< Install PHP 7.2 >>>>>>>>>>>>>>>>>>>>"
yum --enablerepo=remi-php72 install php php-mysql php-xml php-soap php-xmlrpc php-mbstring php-json php-gd php-mcrypt -y
echo "<<<<<<<<<<<<<<<<<< Install and enable Apache >>>>>>>>>>>>>>>>>>>>"
yum --enablerepo=epel,remi install httpd -y
systemctl start httpd.service
systemctl enable httpd.service
echo "<<<<<<<<<<<<<<<<<< Install MySQL >>>>>>>>>>>>>>>>>>>>"
yum install mysql-server -y
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
echo "<<<<<<<<<<<<<<<<<< Check version Apache, PHP, MySql >>>>>>>>>>>>>>>>>>>>"
httpd -v
php -v
mysql -V
yum install php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache -y
systemctl restart httpd.service
echo "<<<<<<<<<<<<<<<<<<  Install GIT  >>>>>>>>>>>>>>>>>>>>"
yum install git -y
cd /opt
echo "<<<<<<<<<<<<<<<<<<  Clone MOODLE >>>>>>>>>>>>>>>>>>>>"
git clone git://git.moodle.org/moodle.git
cd moodle
git branch --track MOODLE_36_STABLE origin/MOODLE_36_STABLE
git checkout MOODLE_36_STABLE
echo "<<<<<<<<<<<<<<<<<<  Copy  >>>>>>>>>>>>>>>>>>>>"
cp -R /opt/moodle /var/www/html/
echo "<<<<<<<<<<<<<<<<<< Make dir  >>>>>>>>>>>>>>>>>>>>"
mkdir /var/moodledata
echo "<<<<<<<<<<<<<<<<<<  Permisions  >>>>>>>>>>>>>>>>>>>>"
chmod -R 0755 /var/www/html/moodle
chown -R apache.apache /var/www/html/moodle 
chmod -R 777 /var/moodledata
chown -R apache.apache /var/moodledata
mysql -u root -p ${rootpasswd} -e "create database moodle;" <<EOF
${DB_ROOT_PWD}
EOF
mysql -u root -p ${rootpasswd} -e "grant all privileges on moodle.* to 'moodle'@'localhost' identified by 'redhat';" <<EOF
${DB_ROOT_PWD}
EOF
echo "<<<<<<<<<<<<<<<<<<  Virtual host  >>>>>>>>>>>>>>>>>>>>"
FILE="/etc/httpd/conf.d/moodle.techoism.com.conf"
/bin/cat <<EOM >$FILE
<VirtualHost *:80>
 ServerName moodle.techoism.com
 DocumentRoot /var/www/html/moodle
 ErrorLog /var/log/httpd/moodle.techoism.com_error_log
 CustomLog /var/log/httpd/moodle.techoism.com_access_log combined 
 DirectoryIndex index.html index.htm index.php index.php4 index.php5
<Directory /var/www/html/moodle>
 Options -Indexes +IncludesNOEXEC +SymLinksIfOwnerMatch
 AllowOverride All
 Require all granted
</Directory>
</VirtualHost>
EOM
systemctl restart httpd.service
echo "<<<<<<<<<<<<<<<<<<  End  >>>>>>>>>>>>>>>>>>>>"
