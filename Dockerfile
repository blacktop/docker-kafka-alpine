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

ENV KAFKA 0.10.0.0
ENV SCALA 2.11

RUN apk-install bash
RUN apk-install -t build-deps curl ca-certificates \
  && mkdir -p /opt \
	&& curl -sSL http://apache.mirrors.ionfish.org/kafka/${KAFKA}/kafka_${SCALA}-${KAFKA}.tgz \
		| tar -xzf - -C /opt \
	&& mv /opt/kafka_${SCALA}-${KAFKA} /opt/kafka \
  && adduser -DH -s /sbin/nologin kafka \
  && chown -R kafka:kafka /opt/kafka \
  && rm -rf /tmp/* \
  && apk del --purge build-deps

ENV PATH $PATH:/opt/kafka/bin/

WORKDIR /opt/kafka

VOLUME ["/tmp/kafka-logs"]

EXPOSE 9092 2181

COPY config /opt/kafka/config
COPY entrypoints/kafka-entrypoint-v2.sh /kafka-entrypoint.sh
RUN chmod +x /kafka-entrypoint.sh

ENTRYPOINT ["/kafka-entrypoint.sh"]

CMD ["kafka-server-start.sh", "config/server.properties"]
