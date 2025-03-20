FROM ubuntu:22.04

# Install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y iputils-ping curl vim openjdk-8-jdk sudo openssh-server

# Add Hadoop user and group
RUN addgroup hadoop && \
    adduser --disabled-password --gecos "" --ingroup hadoop hduser && \
    echo "hduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Setup SSH for Hadoop
RUN mkdir -p /home/hduser/.ssh && \
    ssh-keygen -t rsa -N "" -f /home/hduser/.ssh/id_rsa && \
    cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys && \
    chmod 600 /home/hduser/.ssh/authorized_keys && \
    chown -R hduser:hadoop /home/hduser/.ssh

# Copy Hadoop archive and extract it
COPY ./shared/hadoop-3.3.6.tar.gz /usr/local/
COPY ./shared/entrypoint.sh /entrypoint.sh

RUN tar -xvzf /usr/local/hadoop-3.3.6.tar.gz -C /usr/local/ && \
    mv /usr/local/hadoop-3.3.6 /usr/local/hadoop && \
    chown -R hduser:hadoop /usr/local/hadoop && \
    chmod -R 755 /usr/local/hadoop

RUN mkdir -p /usr/local/hadoop/yarn_data/hdfs/journalnode && \
    chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/journalnode && \
    chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/journalnode


# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Copy Hadoop configuration files
COPY ./shared/configuration/hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh
COPY ./shared/configuration/core-site.xml $HADOOP_CONF_DIR/core-site.xml
COPY ./shared/configuration/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
COPY ./shared/configuration/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
COPY ./shared/configuration/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml

# Create necessary directories for Hadoop
RUN mkdir -p /app/hadoop/tmp && \
    chmod -R 755 /app/hadoop/tmp && \
    chown -R hduser:hadoop /app/hadoop/tmp && \
    mkdir -p /usr/local/hadoop/yarn_data/hdfs/namenode && \
    mkdir -p /usr/local/hadoop/yarn_data/hdfs/datanode && \
    chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/namenode && \
    chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/datanode && \
    chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/namenode && \
    chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/datanode && \
    chown -R hduser:hadoop /usr/local/hadoop

# Switch to Hadoop user
USER hduser

# Expose ports for Hadoop services
EXPOSE 8888 9870 4040 8088 9864 8042 18080 18081 22

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]