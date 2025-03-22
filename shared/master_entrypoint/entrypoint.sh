#!/bin/bash

# # Start SSH service
# sudo service ssh start

# # Start JournalNode daemon
# echo "Starting JournalNode daemon..."
# hdfs --daemon start journalnode

# # Wait for JournalNodes to initialize
# sleep 10

# # Format JournalNode if not formatted
# if [ ! -f /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted ]; then
#     echo "Formatting JournalNode..."
#     hdfs namenode -initializeSharedEdits
#     touch /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted
# fi

# # Format NameNode if not formatted (Only on master1)
# if [ "$(hostname)" == "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
#     echo "Formatting HDFS NameNode on master1..."
#     hdfs namenode -format
#     touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
# fi

# # Sync latest config files
# cp /shared/configuration/all/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
# cp /shared/configuration/all/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml

# # Ensure standby NameNodes are initialized (bootstrap them)
# if [ "$(hostname)" != "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
#     echo "Bootstrapping Standby NameNode on $(hostname)..."
#     hdfs namenode -bootstrapStandby
#     touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
# fi

# # Start Hadoop services
# echo "Starting Hadoop services..."
# $HADOOP_HOME/sbin/start-dfs.sh
# $HADOOP_HOME/sbin/start-yarn.sh

# # Keep container running
# tail -f /dev/null

#!/bin/bash

# Start SSH service
sudo service ssh start

# Start JournalNode daemon
echo "Starting JournalNode daemon..."
hdfs --daemon start journalnode

# Wait for JournalNodes to initialize
sleep 10

# Format JournalNode if not formatted
if [ ! -f /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted ]; then
    echo "Formatting JournalNode..."
    hdfs namenode -initializeSharedEdits
    mkdir -p /usr/local/hadoop/yarn_data/hdfs/journalnode/mycluster
    touch /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted
fi


# Format NameNode if not formatted (Only on master1)
if [ "$(hostname)" == "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
    echo "Formatting HDFS NameNode on master1..."
    hdfs namenode -format
    touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
fi

# Sync latest config files
cp /shared/configuration/all/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp /shared/configuration/all/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml

# Ensure standby NameNodes are initialized (bootstrap them)
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
