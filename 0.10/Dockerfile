FROM gliderlabs/alpine

MAINTAINER blacktop, https://github.com/blacktop

RUN apk-install openjdk8-jre tini su-exec

ENV KAFKA_VERSION 0.10.2.0
ENV SCALA_VERSION 2.12

RUN apk-install bash docker coreutils
RUN apk-install -t .build-deps curl ca-certificates jq \
  && mkdir -p /opt \
	&& mirror=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred') \
	&& curl -sSL "${mirror}kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
		| tar -xzf - -C /opt \
	&& mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
  && adduser -DH -s /sbin/nologin kafka \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

ENV PATH /sbin:/opt/kafka/bin/:$PATH

WORKDIR /opt/kafka

VOLUME ["/tmp/kafka-logs"]

EXPOSE 9092 2181

COPY config/log4j.properties /opt/kafka/config/
COPY config/server.properties /opt/kafka/config/
COPY config/zookeeper.properties /opt/kafka/config/
COPY entrypoints/kafka-entrypoint-v4.sh /kafka-entrypoint.sh
COPY scripts /

ENTRYPOINT ["/kafka-entrypoint.sh"]

CMD ["kafka-server-start.sh", "config/server.properties"]

# HEALTHCHECK --interval=5s --timeout=2s --retries=5 CMD bin/health.sh
