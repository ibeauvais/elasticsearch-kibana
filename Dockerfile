FROM openjdk:8-jre-alpine

RUN apk update && apk add supervisor
RUN apk add openssl

ENV ELASTICSEARCH_VERSION 2.4.0
ENV KIBANA_VERSION 4.6.1

RUN \
  mkdir -p /opt && \
  cd /tmp && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  tar -xzf elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  rm -rf elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  mv elasticsearch-$ELASTICSEARCH_VERSION /opt/elasticsearch &&\
  echo "network.host: 0.0.0.0" >> /opt/elasticsearch/config/elasticsearch.yml


RUN \
  apk add --update --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted nodejs &&\
  cd /tmp && \
  wget https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x86_64.tar.gz && \
  tar -xzf kibana-$KIBANA_VERSION-linux-x86_64.tar.gz && \
  rm -rf kibana-$KIBANA_VERSION-linux-x86_64.tar.gz && \
  mv kibana-$KIBANA_VERSION-linux-x86_64 /opt/kibana &&\
  rm -rf /opt/kibana/node &&\
  mkdir -p /opt/kibana/node/bin && \
  ln -sf /usr/bin/node /opt/kibana/node/bin/node &&\
  /opt/kibana/bin/kibana plugin --install elastic/sense


COPY supervisord.conf /etc/supervisord.conf

EXPOSE 9200 9300 5601

CMD ["/usr/bin/supervisord"]
