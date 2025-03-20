#!/bin/bash

# setup history
apt update && apt upgrade -y
apt install sudo
apt install vim -y
apt install curl -y
apt install iputils-ping -y
apt install openjdk-8-jdk -y
# curl -L https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz -o /usr/local/hadoop-3.3.6.tar.gz

# create hadoop user
addgroup hadoop
adduser hduser --ingroup hadoop
usermod -aG sudo hduser
echo "hduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# setup ssh
apt install openssh-server -y
service ssh start 
mkdir /home/hduser/.ssh/
ssh-keygen -t rsa -f "/home/hduser/.ssh/id_rsa" -N ""
cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys
chown hduser:hadoop -R /home/hduser/.ssh/


# setup environment variables
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >>  /home/hduser/.bashrc
echo "export PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin:$PATH" >> /home/hduser/.bashrc

# download hadoop
cd /usr/local
cp /shared/hadoop-3.3.6.tar.gz /usr/local/
tar -xvzf /usr/local/hadoop-3.3.6.tar.gz
mv /usr/local/hadoop-3.3.6 /usr/local/hadoop
chown -R hduser:hadoop /usr/local/hadoop
chmod -R 777 /usr/local/hadoop

echo "export HADOOP_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc
echo "export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop" >> /home/hduser/.bashrc
echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc
echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc
echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc
echo "export YARN_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc
echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin" >> /home/hduser/.bashrc
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native" >> /home/hduser/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib"' >> /home/hduser/.bashrc
echo "sudo service ssh start" >> /home/hduser/.bashrc

# source environment variables
source /home/hduser/.bashrc

# copy configurations
cp /shared/configuration/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh
cp /shared/configuration/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
cp /shared/configuration/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
cp /shared/configuration/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
cp /shared/configuration/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml

# crete hadoop directories
mkdir -p /app/hadoop/tmp
chmod -R 777 /app/hadoop/tmp
chown -R hduser:hadoop /app/hadoop/tmp
mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode
mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode
chmod -R 777 /usr/local/hadoop/yarn_data/hdfs/namenode
chmod -R 777 /usr/local/hadoop/yarn_data/hdfs/datanode
chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/namenode
chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/datanode

chown -R hduser:hadoop /usr/local/hadoop

