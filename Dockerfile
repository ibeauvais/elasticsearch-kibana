FROM openjdk:8-jre-alpine

RUN addgroup -S elasticsearch && adduser -S -G elasticsearch elasticsearch

RUN apk add --no-cache supervisor openssl bash 'su-exec>=0.2'

ENV ELASTICSEARCH_AND_KIBANA_VERSION 5.2.2
ENV ELASTICSEARCH_PATH /usr/share/elasticsearch
ENV KIBANA_PATH /usr/share/kibana

RUN cd /tmp && \
      wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ELASTICSEARCH_AND_KIBANA_VERSION.tar.gz && \
      tar -xzf elasticsearch-$ELASTICSEARCH_AND_KIBANA_VERSION.tar.gz && \
      rm -rf elasticsearch-$ELASTICSEARCH_AND_KIBANA_VERSION.tar.gz && \
      mv /tmp/elasticsearch-$ELASTICSEARCH_AND_KIBANA_VERSION $ELASTICSEARCH_PATH && \
      echo "network.host: 0.0.0.0" >> $ELASTICSEARCH_PATH/config/elasticsearch.yml && \
      chown -R elasticsearch:elasticsearch $ELASTICSEARCH_PATH


WORKDIR $ELASTICSEARCH_PATH

RUN bin/elasticsearch --version
RUN mkdir $ELASTICSEARCH_PATH/data && \
    chown -R elasticsearch:elasticsearch $ELASTICSEARCH_PATH/data


RUN \
  apk add --update --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted nodejs &&\
  cd /tmp && \
  wget https://artifacts.elastic.co/downloads/kibana/kibana-$ELASTICSEARCH_AND_KIBANA_VERSION-linux-x86_64.tar.gz

RUN cd /tmp && \
    tar -xzf kibana-$ELASTICSEARCH_AND_KIBANA_VERSION-linux-x86_64.tar.gz && \
    rm -rf kibana-$ELASTICSEARCH_AND_KIBANA_VERSION-linux-x86_64.tar.gz && \
    mv kibana-$ELASTICSEARCH_AND_KIBANA_VERSION-linux-x86_64 $KIBANA_PATH && \
    rm -rf $KIBANA_PATH/node && \
    mkdir -p $KIBANA_PATH/node/bin && \
    ln -sf /usr/bin/node $KIBANA_PATH/node/bin/node && \
    sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" $KIBANA_PATH/config/kibana.yml

COPY supervisord.conf /etc/supervisord.conf
VOLUME $ELASTICSEARCH_PATH/data


EXPOSE 9200 9300 5601

CMD ["/usr/bin/supervisord"]
