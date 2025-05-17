FROM an2071497/hadoopimg:1.13

ENV HBASE_VERSION=2.4.9
ENV HBASE_HOME=/usr/local/hbase
ENV PATH=/usr/local/hbase/bin:$PATH

USER root

COPY hbase-2.4.9-bin.tar.gz /usr/local/

RUN tar -xvzf /usr/local/hbase-2.4.9-bin.tar.gz -C /usr/local && \
    mv /usr/local/hbase-2.4.9 /usr/local/hbase && \
    rm /usr/local/hbase-2.4.9-bin.tar.gz && \
    chown -R hduser:hadoop /usr/local/hbase

USER hduser

COPY ./hbase-site.xml /usr/local/hbase/conf/hbase-site.xml

RUN cp /usr/local/hadoop/share/hadoop/common/lib/* /usr/local/hbase/lib/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
