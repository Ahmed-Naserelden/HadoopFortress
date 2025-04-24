#!/bin/bash

echo "Starting SSH service..."
sudo service ssh start

if [ "$ROLE" == "master" ]; then

    echo "Starting JournalNode daemon..."
    hdfs --daemon start journalnode
    sleep 5

    echo "Setting Zookeeper ID..."
    case "$(hostname)" in
        "master1") echo "1" | sudo tee /var/lib/zookeeper/myid ;;
        "master2") echo "2" | sudo tee /var/lib/zookeeper/myid ;;
        "master3") echo "3" | sudo tee /var/lib/zookeeper/myid ;;
    esac

    # Start ZooKeeper
    echo "Starting ZooKeeper..."
    zkServer.sh start
    sleep 5 COPY ./zookeeper/zoo.cfg /usr/local/zookeeper/conf/zoo.cfg


    # Format ZKFC only on master1
    if [ "$(hostname)" == "master1" ] && [ ! -f /home/hduser/formatedzk.out ]; then
        echo "Formatting ZKFC..."
        $HADOOP_HOME/bin/hdfs zkfc -formatZK
        touch /home/hduser/formatedzk.out
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

elif [ "$ROLE" == "worker" ]; then

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

fi

# Keep container running
tail -f /dev/null
