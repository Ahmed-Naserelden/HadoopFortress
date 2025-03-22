#!/bin/bash

sudo service ssh start

echo "Starting JournalNode daemons..."
hdfs --daemon start journalnode

if [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
    echo "Formatting HDFS Namenode..."
    $HADOOP_HOME/bin/hdfs namenode -format
    touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
fi

echo "Starting Hadoop services..."
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

tail -f /dev/null