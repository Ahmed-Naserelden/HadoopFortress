#!/bin/bash

echo "Creating Tez directory in HDFS..."

hdfs dfs -mkdir -p /apps/tez;

echo "Uploading Tez tez.tar.gz to HDFS..."
hdfs dfs -put $TEZ_HOME/share/tez.tar.gz /apps/tez/

echo "Setting permissions for Tez directory..."
hdfs dfs -chown -R hduser:hadoop /apps/tez; hdfs dfs -chmod -R 755 /apps
echo "Uploading Tez jar files to HDFS Completed..."


schematool -dbType postgres -initSchema

sleep 10

# Initialize Hive metastore
hive --service metastore &> /shared/${HOSTNAME}_metastore.log &


tail -f /dev/null