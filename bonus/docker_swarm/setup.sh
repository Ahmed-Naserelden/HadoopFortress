#!/bin/bash

# virsh list --all

# docker swarm init --advertise-addr 192.168.122.1:2377 --listen-addr 192.168.122.1:2377
docker swarm init --advertise-addr 10.145.0.181:2377 --listen-addr 10.145.0.181:2377

docker warm join-token worker
docker swarm join-token manager

# biruni@boma🦉[Hadoop-High-Availability]🚀 docker swarm init --advertise-addr 192.168.122.1:2377 --listen-addr 192.168.122.1:2377
# Swarm initialized: current node (glxmexbweqv3ux2og10uhi9f9) is now a manager.
#
# To add a worker to this swarm, run the following command:
#
#    docker swarm join --token SWMTKN-1-5ukd8fuh22268wv8bocn2esx46fqygzjwkmv5pld50p05xfup2-cov3np9eebyw0wfunhe2kmmbv 192.168.122.1:2377
#
# To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.





