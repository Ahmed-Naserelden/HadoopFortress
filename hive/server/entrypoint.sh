#!/bin/bash

# # start HiveServer2

export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$TEZ_CONF_DIR:$(find $TEZ_HOME -name '*.jar' | paste -sd ':' )

sleep 12

echo "Starting HiveServer2..."
hive --service hiveserver2 &> /shared/${HOSTNAME}_hiveserver2.log &

tail -f /dev/null