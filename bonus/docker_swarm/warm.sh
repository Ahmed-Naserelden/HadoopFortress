#!/bin/bash


docker service ls


docker service ps hdoop_stack


docker stack deploy -c docker-stack.yml hadoop_stack

docker service ls
docker service ps hadoop_stack_hdfs_master1
docker service ps hadoop_stack_hdfs_worker

docker node ls

docker service logs hadoop_stack_hdfs_master1
docker service logs hadoop_stack_hdfs_worker


docker node inspect <node_id>

docker node promote <node_id>


docker task ls


docker swarm leave --force



docker-compose up --scale worker=3

docker-compose up -d --scale worker=3


docker stack rm hadoop_stack


