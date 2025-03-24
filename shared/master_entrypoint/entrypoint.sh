#!/bin/bash

# Start SSH service
sudo service ssh start

sudo chown -R hduser:hadoop /usr/local/hadoop/logs
# sudo chmow -R hduser:hadoop /usr/local/hadoop/logs

# Start JournalNode daemon
echo "Starting JournalNode daemon..."
hdfs --daemon start journalnode

# Wait for JournalNodes to initialize
sleep 5

echo "Setting Zookeeper ID..."
# Set Zookeeper ID
echo "Setting Zookeeper ID..."
case "$(hostname)" in
    "master1") echo "1" > /var/lib/zookeeper/myid ;;
    "master2") echo "2" > /var/lib/zookeeper/myid ;;
    "master3") echo "3" > /var/lib/zookeeper/myid ;;
esac

# **Start Zookeeper First**
echo "Starting ZooKeeper..."
zkServer.sh start

sleep 5

# **Format ZooKeeper Failover Controller (ZKFC) - Only on master1**
if [ "$(hostname)" == "master1" ]; then
    echo "Formatting ZKFC..."
    $HADOOP_HOME/bin/hdfs zkfc -formatZK
fi

sleep 5

# **Start ZKFC on all NameNodes**
echo "Starting ZKFC on $(hostname)..."
$HADOOP_HOME/bin/hdfs --daemon start zkfc

# Sync latest config files
cp /shared/configuration/all/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp /shared/configuration/all/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp /shared/configuration/all/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
cp /shared/configuration/all/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Check if JournalNode is formatted
if [ ! -f /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted ]; then
    echo "Formatting JournalNode..."
    rm -rf /tmp/hadoop/dfs/journalnode/*
    hdfs journalnode -format
    touch /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted
fi

# Format NameNode if not formatted (Only on master1)
if [ "$(hostname)" == "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
    echo "Initializing shared edits..."
    hdfs namenode -initializeSharedEdits
    hdfs namenode -format
    touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
fi

# Bootstrap Standby NameNode
if [ "$(hostname)" != "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
    echo "Bootstrapping Standby NameNode on $(hostname)..."
    hdfs namenode -bootstrapStandby
    touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
fi

# Start Hadoop services
echo "Starting Hadoop services..."
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Keep container running
tail -f /dev/null
