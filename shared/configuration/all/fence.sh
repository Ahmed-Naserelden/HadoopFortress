#!/bin/bash

echo "Fencing NameNode: $target_host"
ssh hduser@$target_host "sudo systemctl stop hadoop-hdfs-namenode"
