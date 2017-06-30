############################################################
# Dockerfile to build Elasticsearch 3.4.2 environment
############################################################

# Set the base image to openjdk:8-jre
FROM openjdk:8-jre

# File Author / Maintainer
MAINTAINER Marcio Godoi <souzagodoi@gmail.com>

# Run as a root user
USER root

ENV LOGSTASH_HOME=/opt/logstash

USER root

# Installing sudo module to support Logstash installation
RUN apt-get update && \
    apt-get -y install sudo vim curl

# Installing Logstash
RUN wget https://artifacts.elastic.co/downloads/logstash/logstash-5.4.1.tar.gz -P /tmp/logstash  && \
    tar -xvzf /tmp/logstash/logstash-5.4.1.tar.gz -C /tmp/logstash && \
    rm -rf /tmp/logstash/logstash-5.4.1.tar.gz && \
    mv /tmp/logstash/logstash-5.4.1 $LOGSTASH_HOME && \
    rm -rf /tmp/logstash

# Install Elasticsearch monitoring plugins
RUN ./bin/elasticsearch-plugin install x-pack

WORKDIR "$LOGSTASH_HOME"

# Install Elasticsearch monitoring plugins
RUN ./bin/logstash-plugin install x-pack

RUN mkdir -p /opt/logstash/logs /opt/logstash/data

# Create elasticsearch group and user
RUN groupadd -g 1000 logstash \
  && useradd -d "$LOGSTASH_HOME" -u 1000 -g 1000 -s /sbin/nologin logstash

ADD bin/entrypoint.sh /opt/logstash/bin/docker-entrypoint.sh

ADD config/logstash.yml /opt/logstash/config/logstash.yml

ADD config/logstash.conf /opt/logstash/config/logstash.conf

RUN chmod 755 /opt/elasticsearch/bin/docker-entrypoint.sh

RUN chown -R logstash:logstash /opt/logstash/config/ /opt/logstash/logs/ /opt/logstash/data/

# Run the container as elasticsearch user
USER logstash

WORKDIR "$LOGSTASH_HOME"

ENTRYPOINT ["/opt/logstash/bin/docker-entrypoint.sh"]

# Exposes http ports
EXPOSE 9200 9300