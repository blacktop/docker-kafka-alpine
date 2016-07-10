FROM gliderlabs/alpine

MAINTAINER blacktop, https://github.com/blacktop

RUN apk-install openjdk8-jre tini

# Grab *gosu* for easy step-down from root
ENV GOSU_VERSION 1.7
ENV GOSU_URL https://github.com/tianon/gosu/releases/download
RUN apk-install -t build-deps wget ca-certificates gpgme \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
  && apk del --purge build-deps

ENV KAFKA_VERSION 0.10.0.0
ENV SCALA_VERSION 2.11

RUN apk-install bash docker coreutils
RUN apk-install -t build-deps curl ca-certificates jq \
  && mkdir -p /opt \
	&& mirror=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred') \
	&& curl -sSL "${mirror}kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
		| tar -xzf - -C /opt \
	&& mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
  && adduser -DH -s /sbin/nologin kafka \
  && chown -R kafka:kafka /opt/kafka \
  && rm -rf /tmp/* \
  && apk del --purge build-deps

ENV PATH $PATH:/opt/kafka/bin/

WORKDIR /opt/kafka

VOLUME ["/tmp/kafka-logs"]

EXPOSE 9092 2181

COPY config /opt/kafka/config
COPY entrypoints/kafka-entrypoint-v4.sh /kafka-entrypoint.sh
COPY create-topics.sh /create-topics.sh
COPY start-kafka.sh /start-kafka.sh
COPY start-zookeeper.sh /start-zookeeper.sh
RUN chmod +x /*.sh

ENTRYPOINT ["/kafka-entrypoint.sh"]

CMD ["kafka-server-start.sh", "config/server.properties"]
