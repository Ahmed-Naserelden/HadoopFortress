#!/bin/bash

source ~/.bashrc
# Start SSH service
echo "Starting SSH service..."
sudo service ssh start

# Ensure correct ownership of Hadoop logs
sudo chown -R hduser:hadoop /usr/local/hadoop/logs

# Start JournalNode daemon
echo "Starting JournalNode daemon..."
hdfs --daemon start journalnode
sleep 5  # Give JournalNodes time to initialize

# Set Zookeeper ID based on hostname
echo "Setting Zookeeper ID..."
case "$(hostname)" in
    "master1") echo "1" | sudo tee /var/lib/zookeeper/myid ;;
    "master2") echo "2" | sudo tee /var/lib/zookeeper/myid ;;
    "master3") echo "3" | sudo tee /var/lib/zookeeper/myid ;;
esac

# Start ZooKeeper
echo "Starting ZooKeeper..."
zkServer.sh start
sleep 5  # Give ZooKeeper time to initialize

# Sync latest Hadoop configuration files
echo "Syncing Hadoop configuration files..."
cp /shared/configuration/master/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp /shared/configuration/master/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp /shared/configuration/master/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
cp /shared/configuration/master/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
cp /shared/configuration/master/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
cp /shared/hive/hive-site.xml $HIVE_HOME/conf/hive-site.xml
cp /shared/postgresql-42.2.23.jar $HIVE_HOME/lib/
cp /shared/tez/tez-site.xml $TEZ_HOME/conf/tez-site.xml
cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar $HIVE_HOME/lib

# Format ZKFC only on master1
if [ "$(hostname)" == "master1" ]; then
    echo "Formatting ZKFC..."
    $HADOOP_HOME/bin/hdfs zkfc -formatZK
fi



# Check if JournalNode is formatted
if [ ! -f /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted ]; then
    echo "Formatting JournalNode..."
    rm -rf /tmp/hadoop/dfs/journalnode/*
    touch /usr/local/hadoop/yarn_data/hdfs/journalnode/formatted
fi

# Format NameNode if not formatted (Only on master1)
if [ "$(hostname)" == "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
    echo "Initializing shared edits..."
    hdfs namenode -initializeSharedEdits

    echo "Formatting NameNode..."
    hdfs namenode -format
    touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
fi

# Bootstrap Standby NameNode (for master2 and master3)
if [ "$(hostname)" != "master1" ] && [ ! -f /usr/local/hadoop/yarn_data/hdfs/namenode/formatted ]; then
    echo "Bootstrapping Standby NameNode on $(hostname)..."
    hdfs namenode -bootstrapStandby
    touch /usr/local/hadoop/yarn_data/hdfs/namenode/formatted
fi

# Start ZKFC on all NameNodes
echo "Starting ZKFC on $(hostname)..."
$HADOOP_HOME/bin/hdfs --daemon start zkfc

# Start Hadoop services
echo "Starting Hadoop services..."
hdfs --daemon start namenode
yarn --daemon start resourcemanager


if [ "$(hostname)" == "master1" ]; then
    sleep 20
    # Start HiveServer2
    echo "Creating Tez directory in HDFS..."
    hdfs dfs -mkdir -p /apps/tez;

    echo "Uploading Tez tez.tar.gz to HDFS..."
    hdfs dfs -put $TEZ_HOME/share/tez.tar.gz /apps/tez/

    echo "Setting permissions for Tez directory..."
    hdfs dfs -chown -R hduser:hadoop /apps/tez
    hdfs dfs -chmod -R 755 /apps

    # rm -rf $TEZ_HOME/metastore_db/
    echo "Uploading Tez jar files to HDFS Completed..."
fi

sleep 5

# start HiveServer2
if [ "$(hostname)" == "master1" ]; then
    echo "Starting Hive services..."
    # Start postgresql service
    schematool -dbType postgres -initSchema
    sleep 10
    # Initialize Hive metastore
    hive --service metastore &> /shared/${HOSTNAME}_metastore.log &
fi

# start HiveServer2
if [ "$(hostname)" == "master2" ]; then
    sleep 20
    # Start HiveServer2
    hive --service hiveserver2 &> /shared/${HOSTNAME}_hiveserver2.log &
fi



# Keep container running
tail -f /dev/null
