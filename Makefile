REPO=blacktop/docker-kafka-alpine
ORG=blacktop
NAME=kafka
BUILD ?= 0.11
LATEST ?= 0.11

all: build size test

build:
	cd $(BUILD); docker build -t $(ORG)/$(NAME):$(BUILD) .

size: build
ifeq "$(BUILD)" "$(LATEST)"
	sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD)| cut -d' ' -f1)-blue/' README.md
	sed -i.bu '/latest/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD))/' README.md
endif
	sed -i.bu '/$(BUILD)/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD))/' README.md

tags:
	docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" $(ORG)/$(NAME)

test:
	docker rm -f kafka || true
	docker --init run -d \
				 --name kafka \
				 -p 9092:9092 \
				 -e KAFKA_ADVERTISED_HOST_NAME=localhost \
				 -e KAFKA_CREATE_TOPICS="test-topic:1:1" $(ORG)/$(NAME):$(BUILD)
	kafka-console-consumer --bootstrap-server localhost:9092 --topic test-topic 2>/dev/null > kafka.out &
	sleep 10; echo "shrinky-dinks" | kafka-console-producer --topic=test-topic --broker-list=localhost:9092
	grep -q "shrinky-dinks" kafka.out
	rm kafka.out

tar:
	docker save $(ORG)/$(NAME):$(BUILD) -o $(NAME).tar

run:
	docker --init run -d \
				 --name kafka \
				 -p 9092:9092 \
				 -e KAFKA_ADVERTISED_HOST_NAME=localhost \
				 -e KAFKA_CREATE_TOPICS="test-topic:1:1" $(ORG)/$(NAME):$(BUILD)

circle:
	http https://circleci.com/api/v1.1/project/github/${REPO} | jq '.[0].build_num' > .circleci/build_num
	http "$(shell http https://circleci.com/api/v1.1/project/github/${REPO}/$(shell cat .circleci/build_num)/artifacts${CIRCLE_TOKEN} | jq '.[].url')" > .circleci/SIZE
	sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell cat .circleci/SIZE)-blue/' README.md
	sed -i.bu '/latest/ s/[0-9.]\{3,5\}MB/$(shell cat .circleci/SIZE)/' README.md
	sed -i.bu '/$(BUILD)/ s/[0-9.]\{3,5\}MB/$(shell cat .circleci/SIZE)/' README.md

clean:
	docker-clean stop
	docker rmi $(ORG)/$(NAME) || true
	docker rmi $(ORG)/$(NAME):$(BUILD) || true

.PHONY: build size tags test tar clean circle
