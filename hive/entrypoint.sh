#!/bin/bash

echo "Syncing Hadoop configuration files..."
cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar $HIVE_HOME/lib

if [[ "$role" == "hiveserver" ]]; then
    sleep 12
    echo "Starting HiveServer2..."
    hive --service hiveserver2 &> /shared/${HOSTNAME}_hiveserver2.log &
else
    echo "Creating Tez directory in HDFS..."
    if hdfs dfs -mkdir -p /apps/tez; then
        echo "Tez directory created successfully."

        echo "Uploading Tez tez.tar.gz to HDFS..."
        if hdfs dfs -put "$TEZ_HOME/share/tez.tar.gz" /apps/tez/; then
            echo "Tez tar.gz uploaded successfully."

            echo "Setting permissions for Tez directory..."
            if hdfs dfs -chown -R hduser:hadoop /apps/tez && hdfs dfs -chmod -R 755 /apps; then
                echo "Permissions set successfully."
                echo "Uploading Tez jar files to HDFS Completed..."
            else
                echo "Failed to set permissions for Tez directory."
                exit 1
            fi

        else
            echo "Failed to upload Tez tar.gz to HDFS."
            exit 1
        fi

    else
        echo "Failed to create Tez directory in HDFS."
        exit 1
    fi

    echo "Initializing Hive schema in PostgreSQL..."
    if schematool -dbType postgres -initSchema; then
        echo "Schema initialization successful."
    else
        echo "Schema initialization failed."
        exit 1
    fi

    hive --service metastore &> /shared/${HOSTNAME}_metastore.log &
fi

tail -f /dev/null