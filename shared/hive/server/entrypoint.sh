#!/bin/bash

# # start HiveServer2

export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$TEZ_CONF_DIR:$(find $TEZ_HOME -name '*.jar' | paste -sd ':' )

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

sleep 12

echo "Starting HiveServer2..."
hive --service hiveserver2 &> /shared/${HOSTNAME}_hiveserver2.log &

tail -f /dev/null
