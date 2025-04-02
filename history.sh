#!/bin/bash

apt update

apt upgrade

apt install -y curl 

apt install -y sudo 

apt install -y iputils-ping 

apt install -y vim 

apt install -y openjdk-8-jdk 

vim /home/hduser/.profile
# << 
# JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64


apt install -y openssh-server

service start ssh

addgroup hadoop

adduser --disabled-password --gecos "" --ingroup hadoop hduser

vim /home/hduser/.profile
# set java env variable
# hduser ALL=(ALL) NOPASSWD: ALL

mkdir -p /home/hduser/.ssh

ssh-keygen -t rsa -N "" -f /home/hduser/.ssh/id_rsa

cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys

chmod 600 /home/hduser/.ssh/authorized_keys

chown -R hduser:hadoop /home/hduser/.ssh


cp /shared/hadoop-3.3.6.tar.gz /usr/local/

tar -xvzf /usr/local/hadoop-3.3.6.tar.gz -C /usr/local/

mv /usr/local/hadoop-3.3.6 /usr/local/hadoop

chown -R hduser:hadoop /usr/local/hadoop

chmod -R 755 /usr/local/hadoop


vim /home/hduser/.profile
# set hadoop env variables

# HADOOP_HOME=/usr/local/hadoop
# HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
# HADOOP_MAPRED_HOME=/usr/local/hadoop
# HADOOP_COMMON_HOME=/usr/local/hadoop
# HADOOP_HDFS_HOME=/usr/local/hadoop
# YARN_HOME=/usr/local/hadoop
# HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native
# HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib
# PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/zookeeper/bin

mkdir -p /usr/local/hadoop/yarn_data/hdfs/journalnode
chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/journalnode
chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/journalnode

cp /shared/configuration/hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh
cp /shared/configuration/core-site.xml $HADOOP_CONF_DIR/core-site.xml
cp /shared/configuration/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
cp /shared/configuration/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
cp /shared/configuration/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml


mkdir -p /app/hadoop/tmp
chmod -R 755 /app/hadoop/tmp
chown -R hduser:hadoop /app/hadoop/tmp
mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode
mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode
chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/namenode
chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/datanode
chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/namenode
chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/datanode
chown -R hduser:hadoop /usr/local/hadoop

mkdir -p /usr/local/hadoop/logs
chmod -R 755 /usr/local/hadoop/logs
chown -R hduser:hadoop /usr/local/hadoop/logs


cp /shared/apache-zookeeper-3.8.4-bin.tar.gz /usr/local/

tar -xvzf /usr/local/apache-zookeeper-3.8.4-bin.tar.gz -C /usr/local/
mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper
chown -R hduser:hadoop /usr/local/zookeeper
chmod -R 755 /usr/local/zookeeper


mkdir -p /var/lib/zookeeper
chmod -R 755 /var/lib/zookeeper
chown -R hduser:hadoop /var/lib/zookeeper

cp /shared/zookeeper/zoo.cfg /usr/local/zookeeper/conf/zoo.cfg

su - hduser

/entrypoint.sh