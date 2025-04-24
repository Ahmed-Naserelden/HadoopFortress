FROM ubuntu:22.04

# Environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    HADOOP_HOME=/usr/local/hadoop \
    HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop \
    HADOOP_MAPRED_HOME=/usr/local/hadoop \
    HADOOP_COMMON_HOME=/usr/local/hadoop \
    HADOOP_HDFS_HOME=/usr/local/hadoop \
    YARN_HOME=/usr/local/hadoop \
    HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native \
    HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib" \
    PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/zookeeper/bin

# Install required packages
RUN apt update && \
    apt upgrade -y && \
    apt install -y vim curl openjdk-8-jdk sudo openssh-server && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Add hadoop group and user
RUN addgroup hadoop && \
    adduser --disabled-password --gecos "" --ingroup hadoop hduser && \
    echo "hduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set up SSH for hduser
RUN mkdir -p /home/hduser/.ssh && \
    ssh-keygen -t rsa -N "" -f /home/hduser/.ssh/id_rsa && \
    cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys && \
    chmod 600 /home/hduser/.ssh/authorized_keys && \
    chown -R hduser:hadoop /home/hduser/.ssh

# Add environment vars to .profile
RUN echo "\n# Hadoop & Java Env Vars" >> /home/hduser/.profile && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /home/hduser/.profile && \
    echo "export HADOOP_HOME=$HADOOP_HOME" >> /home/hduser/.profile && \
    echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> /home/hduser/.profile && \
    echo "export PATH=\$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:/usr/local/zookeeper/bin" >> /home/hduser/.profile && \
    echo "export HADOOP_OPTS=\"$HADOOP_OPTS\"" >> /home/hduser/.profile

# Install Hadoop
RUN curl -L https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz -o /tmp/hadoop.tar.gz && \
    tar -xvzf /tmp/hadoop.tar.gz -C /usr/local && \
    mv /usr/local/hadoop-3.3.6 /usr/local/hadoop && \
    rm /tmp/hadoop.tar.gz && \
    mkdir -p /usr/local/hadoop/yarn_data/hdfs/{journalnode,namenode,datanode} \
             /usr/local/hadoop/logs \
             /app/hadoop/tmp && \
    chmod -R 755 /usr/local/hadoop /app/hadoop/tmp && \
    chown -R hduser:hadoop /usr/local/hadoop /app/hadoop/tmp

# Install ZooKeeper
RUN curl -L https://dlcdn.apache.org/zookeeper/zookeeper-3.8.4/apache-zookeeper-3.8.4-bin.tar.gz -o /tmp/zookeeper.tar.gz && \
    tar -xvzf /tmp/zookeeper.tar.gz -C /usr/local && \
    mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper && \
    rm /tmp/zookeeper.tar.gz && \
    mkdir -p /var/lib/zookeeper && \
    chmod -R 755 /usr/local/zookeeper /var/lib/zookeeper && \
    chown -R hduser:hadoop /usr/local/zookeeper /var/lib/zookeeper

# Copy Hadoop and ZooKeeper configuration files
COPY ./hadoop-config/*.xml $HADOOP_CONF_DIR/
COPY ./hadoop-config/hadoop-env.sh $HADOOP_CONF_DIR/
COPY ./zookeeper/zoo.cfg /usr/local/zookeeper/conf/zoo.cfg
COPY ./hadoop-config/entrypoint.sh /entrypoint.sh

# Switch to hduser
USER hduser

# Expose web UIs and YARN
EXPOSE 9870 8088

# Start the container
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
