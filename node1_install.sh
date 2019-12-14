#!/bin/bash

# variables
password="Cluster^123"

# mysql installation
sudo su -

sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/sysconfig/selinux 
setenforce 0 # I had problems on creation of cluster level because of SELinux

yum install -y wget
wget https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
yum localinstall -y mysql80-community-release-el8-1.noarch.rpm
yum update -y
yum install -y mysql-server mysql-shell
systemctl start mysqld

# cluster configuration
mysql -e "create user 'mycluster' identified by $password"
mysql -e "grant all privileges on *.* to 'mycluster'@'%' with grant option"
mysql -e "reset master"

sleep 120 # waiting as all nodes will be ready 

mysqlsh -e "dba.configureInstance('mycluster@mysql01',{password:'$password',interactive:false,restart:true})"
mysqlsh -e "dba.configureInstance('mycluster@mysql02',{password:'$password',interactive:false,restart:true})"
mysqlsh -e "dba.configureInstance('mycluster@mysql03',{password:'$password',interactive:false,restart:true})"

mysqlsh mycluster@mysql01 --password=$password -e "dba.createCluster('mycluster')"
mysqlsh mycluster@mysql01 --password=$password -e "cluster.addInstance('mycluster@mysql2:3306',{password:'$password'})"
mysqlsh mycluster@mysql01 --password=$password -e "cluster.addInstance('mycluster@mysql3:3306',{password:'$password'})"