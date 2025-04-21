FROM ubuntu:22.04

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
ENV HIVE_HOME=/usr/local/hive
ENV TEZ_HOME=/usr/local/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:usr/local/zookeeper/bin:/usr/local/hive/bin:/usr/local/tez/bin

# Install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y iputils-ping vim openjdk-8-jdk sudo openssh-server

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

RUN tar -xvzf /usr/local/hadoop-3.3.6.tar.gz -C /usr/local/ && \
    mv /usr/local/hadoop-3.3.6 /usr/local/hadoop && \
    chown -R hduser:hadoop /usr/local/hadoop && \
    chmod -R 755 /usr/local/hadoop && \
    rm /usr/local/hadoop-3.3.6.tar.gz && \
    mkdir -p /usr/local/hadoop/yarn_data/hdfs/journalnode && \
    chmod -R 755 /usr/local/hadoop/yarn_data/hdfs/journalnode && \
    chown -R hduser:hadoop /usr/local/hadoop/yarn_data/hdfs/journalnode

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
    chown -R hduser:hadoop /usr/local/hadoop && \
    mkdir -p /usr/local/hadoop/logs && \
    chmod -R 755 /usr/local/hadoop/logs && \
    chown -R hduser:hadoop /usr/local/hadoop/logs

# ----------------------------
COPY ./shared/apache-zookeeper-3.8.4-bin.tar.gz /usr/local/
RUN tar -xvzf /usr/local/apache-zookeeper-3.8.4-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-zookeeper-3.8.4-bin /usr/local/zookeeper && \
    chown -R hduser:hadoop /usr/local/zookeeper && \
    chmod -R 755 /usr/local/zookeeper && \
    rm /usr/local/apache-zookeeper-3.8.4-bin.tar.gz && \
    mkdir -p /var/lib/zookeeper && \
    chmod -R 755 /var/lib/zookeeper && \
    chown -R hduser:hadoop /var/lib/zookeeper

COPY ./shared/zookeeper/zoo.cfg /usr/local/zookeeper/conf/zoo.cfg

# ======================================================================
# ======================================================================


COPY ./shared/apache-hive-4.0.1-bin.tar.gz /usr/local/
RUN tar -xzf /usr/local/apache-hive-4.0.1-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-hive-4.0.1-bin /usr/local/hive && \
    chown -R hduser:hadoop /usr/local/hive && \
    rm /usr/local/apache-hive-4.0.1-bin.tar.gz

# --- --- -- -- - -- -- - -- - -- ------ - -- - -- -- - - -- - -

COPY ./shared/apache-tez-0.10.4-bin.tar.gz /usr/local/
RUN tar -xvzf /usr/local/apache-tez-0.10.4-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-tez-0.10.4-bin /usr/local/tez && \
    chown -R hduser:hadoop /usr/local/tez/ && \
    rm /usr/local/apache-tez-0.10.4-bin.tar.gz

# ======================================================================
# ======================================================================

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /home/hduser/.bashrc &&\
    echo "export HADOOP_HOME=/usr/local/hadoop" >> /home/hduser/.profile &&\
    echo "export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop" >> /home/hduser/.bashrc &&\
    echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc &&\
    echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc &&\
    echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc &&\
    echo "export YARN_HOME=/usr/local/hadoop" >> /home/hduser/.bashrc &&\
    echo "export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib/native" >> /home/hduser/.bashrc &&\
    echo "export HADOOP_OPTS="-Djava.library.path=/usr/local/hadoop/lib"" >> /home/hduser/.bashrc &&\
    echo "export HIVE_HOME=/usr/local/hive" >> /home/hduser/.bashrc &&\
    echo "export TEZ_HOME=/usr/local/tez" >> /home/hduser/.bashrc &&\
    echo "export TEZ_CONF_DIR=/usr/local/tez/conf" >> /home/hduser/.bashrc &&\
    echo "export TEZ_JARS=/path/to/tez/lib/*" >>  /home/hduser/.bashrc && \
    echo "export HIVE_AUX_JARS_PATH=$TEZ_JARS" >>  /home/hduser/.bashrc && \
    echo "export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$TEZ_CONF_DIR:$(find $TEZ_HOME -name '*.jar' | paste -sd ':' ):/usr/local/tez/conf:/usr/local/tez/tez-mapreduce-0.10.4.jar" >> /home/hduser/.bashrc &&\
    # echo "export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/usr/local/tez/conf:/usr/local/tez/tez-mapreduce-0.10.4.jar" >> /home/hduser/.bashrc &&\


    # echo "export HADOOP_CLASSPATH=$TEZ_HOME/*:$TEZ_HOME/lib/*:$HADOOP_CLASSPATH" >> /home/hduser/.profile &&\
    # echo "export TEZ_JARS=$(find $TEZ_HOME -name '*.jar' | tr '\n' ':')" >>  /home/hduser/.profile &&\
    # echo "export HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}:${HADOOP_CLASSPATH}" >>  /home/hduser/.profile &&\
    echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/zookeeper/bin:/usr/local/hive/bin:/usr/local/tez/bin" >> /home/hduser/.profile
# ENV HIVE_AUX_JARS_PATH=$TEZ_HOME

# Switch to Hadoop user
USER hduser

# Expose ports for Hadoop services
EXPOSE 9870 8088

# Set entrypoint
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]

# docker build -t an2071497/hadoopimg:1.15 .

