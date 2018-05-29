#!/bin/bash
#mysql用户名和密码
mysqlrootpassword="yinqing1"
projectdir="/usr/local/xssScanner"
xssScannerpassword="yinqing1"

##################### firefox 检测 BEGIN #############################
echo "---------------- firefox59 安装检测 ------------------"
firefox_version=`firefox --version | grep 59`  #检测是否存在firefox 59版本
if [[ $firefox_version != "" ]];then
   echo "firefox 59 has installed."
else
   echo "it is going to install firefox 59."
   #firefox（59.0.1）安装  BEGIN
        cd ${projectdir}"/installer"
        tar xjvf firefox-59.0.1.tar.bz2
        rm -rf /usr/bin/firefox #删除已有软链接
        ln -s ${projectdir}"/installer/firefox/firefox" /usr/bin/firefox  #firefox 建立软链接
  echo `firefox -V`
#firefox（59.0.1）安装  END
fi
##################### python2.7 检测 BEGIN ###################
echo "---------------- python 2.7 安装检测 ------------------"
python_version=`rpm -qa|grep "python-2.7"`
if [[ $python_version != "" ]];then
    echo "python2.7 has installed."
else
    echo "it is going to install python2.7."s
    #python2.7.12安装
    wget  https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
    tar xf Python-2.7.12.tgz   #解压
    cd Python-2.7.12
    ./configure --prefix=/usr/local
    make && make install  #编译、安装成功后能在/usr/local/bin/python2.7找到Python2.7
    rm -rf /usr/bin/python #删除已有软链接 
    ln -s  /usr/bin/python2.7 /usr/bin/python
fi

##################### mysql 检测 BEGIN ##########################
echo "---------------- mysql 安装检测 -----------------------"
mysql_version=`rpm -qa|grep "mysql"`
if [[ $mysql_version != "" ]];then
    echo "mysql has installed."
else
    echo "it is going to install mysql5.7"
        #mysql5.6安装
        yum -y remove `rpm -qa|grep mysql`
        wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
        rpm -ivh mysql-community-release-el7-5.noarch.rpm
        yum -y install mysql-server mysql-client mysql-common mysql-utilities
fi
        service mysqld start

#创建xsspayloads数据库 BEGIN ================================
echo "创建xsspayloads数据库及xssScaner_user用户"
SQLCODE="
create database xsspayloads;
create user 'xssScaner_user'@'localhost' identified by \"$xssScannerpassword\";
GRANT SELECT,INSERT,UPDATE,DELETE ON xsspayloads.* TO 'xssScaner_user'@'localhost';
flush privileges;
"
#sql code 修改root免登陆并需要密码
SQLCODEROOT="use mysql;
update user set password=password(\"$mysqlrootpassword\") where user='root';
flush privileges;"

# Execute SQL code  echo回显执行结果至屏幕
echo $SQLCODE | mysql -u root
echo $SQLCODEROOT |mysql -u root
#创建数据表，导入数据
echo "创建数据表，导入检测数据"
mysql -uroot -p$mysqlrootpassword <${projectdir}"/installer/database.sql"

#设置开机启动
systemctl enable  mysqld.service

###################################################################

#====================== python库安装 BEGIN =====================
wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate
python get-pip.py


echo "MySQL-python python包安装............."

pip install protobuf==3.0.0
pip install mysql-connector-python-rf==2.1.3

echo "lxml（4.2.1） python包安装............."
python -m pip install lxml==4.2.1

echo "selenium(3.6.0)  python包安装............."
python -m pip install selenium==3.6.0

echo "geckodriver 0.20.1  firefox驱动安装............."
rm -rf /usr/bin/geckodriver  #删除已有软链接
ln -s ${projectdir}"/installer/geckodriver" /usr/bin/geckodriver
