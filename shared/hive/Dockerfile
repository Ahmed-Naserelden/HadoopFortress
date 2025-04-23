FROM an2071497/hadoopimg:1.15

USER root

COPY ./shared/apache-hive-4.0.1-bin.tar.gz /usr/local/
RUN tar -xzf /usr/local/apache-hive-4.0.1-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-hive-4.0.1-bin /usr/local/hive && \
    chown -R hduser:hadoop /usr/local/hive && \
    rm /usr/local/apache-hive-4.0.1-bin.tar.gz

COPY ./shared/apache-tez-0.10.4-bin.tar.gz /usr/local/
RUN tar -xvzf /usr/local/apache-tez-0.10.4-bin.tar.gz -C /usr/local/ && \
    mv /usr/local/apache-tez-0.10.4-bin /usr/local/tez && \
    chown -R hduser:hadoop /usr/local/tez/ && \
    rm /usr/local/apache-tez-0.10.4-bin.tar.gz

RUN echo "export HIVE_HOME=/usr/local/hive" >> /home/hduser/.bashrc &&\
    echo "export TEZ_HOME=/usr/local/tez" >> /home/hduser/.bashrc &&\
    echo "export TEZ_CONF_DIR=/usr/local/tez/conf" >> /home/hduser/.bashrc &&\
    echo "export TEZ_JARS=/usr/local/tez/lib/*" >>  /home/hduser/.bashrc && \
    echo "export HIVE_AUX_JARS_PATH=/usr/local/tez/lib/*" >>  /home/hduser/.bashrc && \
    echo "export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/usr/local/tez/conf:$(find /usr/local/tez -name '*.jar' | paste -sd ':' ):/usr/local/tez/conf:/usr/local/tez/tez-mapreduce-0.10.4.jar" >> /home/hduser/.bashrc &&\
    echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/zookeeper/bin:/usr/local/hive/bin:/usr/local/tez/bin" >> /home/hduser/.bashrc


USER hduser

COPY ./hive-site.xml $HIVE_HOME/conf/hive-site.xml
COPY ./postgresql-42.2.23.jar $HIVE_HOME/lib/
COPY ./tez/tez-site.xml $TEZ_HOME/conf/tez-site.xml

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]

