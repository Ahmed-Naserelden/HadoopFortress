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

#--!/bin/bash

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
    hdfs journalnode -format
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



if [ "$(hostname)" == "master1" ]; then
    echo "1" > /var/lib/zookeeper/myid
fi

if [ "$(hostname)" == "master2" ]; then
    echo "2" > /var/lib/zookeeper/myid
fi

if [ "$(hostname)" == "master3" ]; then
    echo "3" > /var/lib/zookeeper/myid
fi

# # **Format ZooKeeper Failover Controller (ZKFC)**
# if [ "$(hostname)" == "master1" ]; then
#     echo "Formatting ZKFC..."
#     $HADOOP_HOME/bin/hdfs zkfc -formatZK
# fi

# Start Zookeeper
# echo "Starting Zookeeper..."
# zkServer.sh start


# Start Hadoop services
echo "Starting Hadoop services..."
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Keep container running
tail -f /dev/null















# yarn-site.xml -------------

# <?xml version="1.0"?>
# <!--
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License. See accompanying LICENSE file.
# -->
# <configuration>
#     <property>
#         <name>yarn.nodemanager.aux-services</name>
#         <value>mapreduce_shuffle</value>
#     </property>
#     <property>
#         <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
#         <value>org.apache.hadoop.mapred.ShuffleHandler</value>
#     </property>

#     <!-- Enable ResourceManager HA -->
#     <!-- <property>
#         <name>yarn.resourcemanager.ha.enabled</name>
#         <value>true</value>
#     </property>

#     <!-- Define the ResourceManager IDs -->
#     <property>
#         <name>yarn.resourcemanager.cluster-id</name>
#         <value>mycluster</value>
#     </property>

#     <property>
#         <name>yarn.resourcemanager.ha.rm-ids</name>
#         <value>rm1,rm2,rm3</value>
#     </property>

#     <!-- Define the hostname of each ResourceManager -->
#     <property>
#         <name>yarn.resourcemanager.hostname.rm1</name>
#         <value>master1</value>
#     </property>
#     <property>
#         <name>yarn.resourcemanager.hostname.rm2</name>
#         <value>master2</value>
#     </property>
#     <property>
#         <name>yarn.resourcemanager.hostname.rm3</name>
#         <value>master3</value>
#     </property>
#     <property>
#       <name>yarn.resourcemanager.webapp.address.rm1</name>
#       <value>master1:8088</value>
#     </property>
#     <property>
#       <name>yarn.resourcemanager.webapp.address.rm2</name>
#       <value>master2:8088</value>
#     </property>
#     <property>
#       <name>yarn.resourcemanager.webapp.address.rm3</name>
#       <value>master3:8088</value>
#     </property> -->

#     <!-- Configure ZooKeeper for YARN HA -->
#     <!-- <property>
#         <name>yarn.resourcemanager.zk-address</name>
#         <value>master1:2181,master2:2181,master3:2181</value>
#     </property>

#     <property>
#         <name>yarn.resourcemanager.recovery.enabled</name>
#         <value>true</value>
#     </property>

#     <property>
#         <name>yarn.resourcemanager.store.class</name>
#         <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>
#     </property> -->

# </configuration>
