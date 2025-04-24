
# Hadoop Fortress: High Availability Cluster on Docker

A fully containerized, production-grade Hadoop cluster featuring **High Availability (HA)** across the board — **NameNode**, **ResourceManager**, and **ZooKeeper** for seamless failover. Whether you're building big data pipelines, running MapReduce jobs, or exploring distributed computing, this HA cluster is built to be resilient, scalable, and rock-solid.

![Architecture Diagram](/design/arch.png)

---

## Key Features

- **HA NameNode Architecture** – 3-node setup with **automatic failover**
- **YARN ResourceManager HA** – 3-node RM cluster with standby capability
- **Shared Edits with JournalNodes** – Consistency via Quorum Journal Manager
- **ZooKeeper Ensemble** – Coordination and leader election
- **Health Monitoring** – Built-in health checks for critical services

---

## Cluster Overview

### Master Nodes (x3)
- **NameNode (HA)**
- **JournalNode**
- **ZooKeeper**
- **ResourceManager (HA)**

### Worker Nodes
- **DataNode**
- **NodeManager**

---

## Configuration Details

### `core-site.xml`
- Defines the **default filesystem** as: `hdfs://mycluster`

### `hdfs-site.xml`
- Configures **3 HA NameNodes** (nn1, nn2, nn3)
- Uses **Quorum Journal Manager** with JournalNodes
- Enables **automatic failover** with ZooKeeper
- Sets **fencing method** via SSH
- Points to data directories for HDFS

### `yarn-site.xml`
- Sets up **YARN ResourceManager HA**
- Enables **MapReduce shuffle service**
- Stores RM state using **ZooKeeper**

### `mapred-site.xml`
- Configures MapReduce runtime environment

### `zoo.cfg`
- Defines a **3-node ZooKeeper ensemble**
- Sets timing and synchronization parameters

### `entrypoint.sh`
- Container initialization script — bootstraps services

---

## Prerequisites

- Docker
- Docker Compose
- At least **8GB RAM** recommended

---

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/Ahmed-Naserelden/HadoopFortress.git
cd HadoopFortress
```

### 2. Launch the Cluster
```bash
docker-compose up -d
```

### 3. Access the Web UIs

#### NameNode
| Node       | URL                          |
|------------|------------------------------|
| Master1    | [localhost:9879](http://localhost:9879) |
| Master2    | [localhost:9880](http://localhost:9880) |
| Master3    | [localhost:9881](http://localhost:9881) |

#### ResourceManager
| Node       | URL                          |
|------------|------------------------------|
| Master1    | [localhost:8078](http://localhost:8078) |
| Master2    | [localhost:8079](http://localhost:8079) |
| Master3    | [localhost:8080](http://localhost:8080) |

---

## Port Mappings

| Service             | Master1 | Master2 | Master3 |
|---------------------|---------|---------|---------|
| NameNode Web UI     | 9879    | 9880    | 9881    |
| ResourceManager UI  | 8078    | 8079    | 8080    |

---

## Cluster Management

### Check Service Status

#### HDFS HA Status
```bash
hdfs haadmin -getAllServiceState
```

#### YARN ResourceManager Status
```bash
yarn rmadmin -getAllServiceState
```

---

## Test the Cluster

### 1. Verify HDFS
```bash
hdfs dfs -mkdir /data
hdfs dfs -put <localfile> /data
hdfs dfs -ls /data
```

### 2. Run a MapReduce Job
```bash
hadoop distcp /data/* /
```

### 3. Check Running YARN Apps
```bash
yarn application -list
```

---

## Environment Variables

| Variable | Description                        |
|----------|------------------------------------|
| `ROLE`   | Either `master` or `worker`        |

---

## Add More Worker Nodes

Spin up another worker dynamically:

```bash
docker container run --name worker2 -h worker2 --network cluster_net -e ROLE=worker -v worker2-datanode:/home/hadoop/hadoopdata/hdfs/datanode han2071497/hadoopimg:1.13
```

---

## Health Monitoring

Each container includes smart health checks:

### Master Nodes
- `QuorumPeerMain`, `NameNode`, `DFSZKFailoverController`, `ResourceManager`, `JournalNode`

### Worker Nodes
- `DataNode`, `NodeManager`

---

## Reference Docs

- [HDFS High Availability](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html#Deployment)
- [YARN ResourceManager HA](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/ResourceManagerHA.html)

---

## Final Notes

This HA cluster is a great starting point for exploring **distributed storage**, **fault-tolerant computing**, and **HA architectures** — all wrapped in an easy-to-deploy Docker environment. Ideal for experimentation, testing, or even production-grade setups.
