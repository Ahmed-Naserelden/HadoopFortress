#!/bin/bash

# Start SSH service
sudo service ssh start

# Ensure permissions
sudo chown -R hduser:hadoop /usr/local/hadoop/logs

# Sync latest configuration files
cp /shared/configuration/worker/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp /shared/configuration/worker/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp /shared/configuration/worker/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
cp /shared/configuration/worker/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Check if DataNode is formatted
if [ ! -f /usr/local/hadoop/yarn_data/hdfs/datanode/formatted ]; then
    echo "Formatting DataNode..."
    rm -rf /usr/local/hadoop/yarn_data/hdfs/datanode/*
    hdfs datanode -format
    touch /usr/local/hadoop/yarn_data/hdfs/datanode/formatted
fi

# Start DataNode service
echo "Starting DataNode..."
hdfs --daemon start datanode

# Start NodeManager service
echo "Starting NodeManager..."
yarn --daemon start nodemanager

# Keep container running
tail -f /dev/null
