FROM an2071497/hadoopimg:1.13

ENV HIVE_HOME=/usr/local/hive
ENV TEZ_HOME=/usr/local/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:usr/local/zookeeper/bin:/usr/local/hive/bin:/usr/local/tez/bin

USER root

RUN curl -L https://dlcdn.apache.org/hive/hive-4.0.1/apache-hive-4.0.1-bin.tar.gz -o /tmp/hive.tar.gz && \
    tar -xzf /tmp/hive.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-hive-4.0.1-bin /usr/local/hive && \
    chown -R hduser:hadoop /usr/local/hive && \
    rm /tmp/hive.tar.gz

RUN curl -L https://dlcdn.apache.org/tez/0.10.4/apache-tez-0.10.4-bin.tar.gz -o /tmp/tez.tar.gz && \
    tar -xvzf /tmp/tez.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-tez-0.10.4-bin /usr/local/tez && \
    chown -R hduser:hadoop /usr/local/tez/ && \
    rm /tmp/tez.tar.gz

RUN echo "export HIVE_HOME=/usr/local/hive" >> /home/hduser/.bashrc &&\
    echo "export TEZ_HOME=/usr/local/tez" >> /home/hduser/.bashrc &&\
    echo "export TEZ_CONF_DIR=/usr/local/tez/conf" >> /home/hduser/.bashrc &&\
    echo "export TEZ_JARS=/usr/local/tez/lib/*" >>  /home/hduser/.bashrc && \
    echo "export HIVE_AUX_JARS_PATH=/usr/local/tez/lib/*" >>  /home/hduser/.bashrc && \
    echo "export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/usr/local/tez/conf:$(find /usr/local/tez -name '*.jar' | paste -sd ':' ):/usr/local/tez/conf:/usr/local/tez/tez-mapreduce-0.10.4.jar" >> /home/hduser/.bashrc &&\
    echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/zookeeper/bin:/usr/local/hive/bin:/usr/local/tez/bin" >> /home/hduser/.bashrc

USER hduser

COPY ./postgresql-42.2.23.jar $HIVE_HOME/lib/
COPY ./hive-config/hive-site.xml $HIVE_HOME/conf/hive-site.xml
COPY ./tez-config/tez-site.xml $TEZ_HOME/conf/tez-site.xml
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
