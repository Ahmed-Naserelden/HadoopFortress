#!/bin/bash


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



echo "Creating Tez directory in HDFS..."
hdfs dfs -mkdir -p /apps/tez;

echo "Uploading Tez tez.tar.gz to HDFS..."
hdfs dfs -put $TEZ_HOME/share/tez.tar.gz /apps/tez/

echo "Setting permissions for Tez directory..."
hdfs dfs -chown -R hduser:hadoop /apps/tez; hdfs dfs -chmod -R 755 /apps
echo "Uploading Tez jar files to HDFS Completed..."


cat ~/.bashrc &> /shared/terr.log

echo "Starting Hive services..."
# Start postgresql service
schematool -dbType postgres -initSchema
sleep 10
# Initialize Hive metastore
hive --service metastore &> /shared/${HOSTNAME}_metastore.log &


tail -f /dev/null
