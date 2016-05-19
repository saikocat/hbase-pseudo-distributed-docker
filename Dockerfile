FROM janeczku/alpine-kubernetes:3.3
MAINTAINER saikocat

ENV HBASE_VERSION=1.1.5
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV SERVICE_USER=app
ENV HBASE_DATA_DIR=/data/hbase

# Add app user
RUN addgroup -g 999 $SERVICE_USER \
	&& adduser -D -G $SERVICE_USER -s /bin/false -u 999 $SERVICE_USER

RUN apk add --update bash curl rsyslog

# Install OpenJDK
RUN apk add --no-cache openjdk7
RUN ln -sf "${JAVA_HOME}/bin/"* "/usr/bin/"

# Install HBase
RUN mkdir -p /opt \
	&& curl -fLs "https://www.apache.org/dyn/closer.cgi?filename=hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz&action=download" \
	|  tar xzf - -C /opt \
	&& mv /opt/hbase-${HBASE_VERSION} /opt/hbase

# HBase Conf
ADD conf/hbase-site.xml /opt/hbase/conf/
RUN mkdir -p /opt/hbase/logs \
	&& chown -R $SERVICE_USER:$SERVICE_USER /opt/hbase/logs
RUN ln -sf "/opt/hbase/bin/"* "/usr/bin/"

# Zookeeper
EXPOSE 2181

# Servers: [Master, RegionServer]
EXPOSE 16000 16020 16030

# APIs: [Thrift]
EXPOSE 9090

# Web UIs: [Master_UI, Thrift_UI]
EXPOSE 16010 9095

# Service - doesn't support bash expansion :(
RUN mkdir -p /etc/services.d/zookeeper \
	mkdir -p /etc/services.d/hbase-region \
	mkdir -p /etc/services.d/hbase-master
COPY service/zookeeper.sh /etc/services.d/zookeeper/run
COPY service/hbase-region.sh /etc/services.d/hbase-region/run
COPY service/hbase-master.sh /etc/services.d/hbase-master/run
RUN chmod 755 /etc/services.d/zookeeper/run \
	&& chmod 755 /etc/services.d/hbase-region/run \
	&& chmod 755 /etc/services.d/hbase-master/run

# Data volume
RUN mkdir -p $HBASE_DATA_DIR \
	&& chown -R $SERVICE_USER:$SERVICE_USER $HBASE_DATA_DIR
VOLUME ["$HBASE_DATA_DIR"]

# Cleanup
RUN rm -rf /var/cache/apk/*
