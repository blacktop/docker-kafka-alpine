lear.PHONY: build size tags test tar push run ssh stop circle

REPO=blacktop/docker-kafka-alpine
ORG=blacktop
NAME=kafka
BUILD ?=$(shell cat LATEST)
LATEST ?=$(shell cat LATEST)

all: build size test

build: ## Build docker image
	cd $(BUILD); docker build -t $(ORG)/$(NAME):$(BUILD) .

size: build ## Get built image size
ifeq "$(BUILD)" "$(LATEST)"
	sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD)| cut -d' ' -f1)-blue/' README.md
	sed -i.bu '/latest/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD))/' README.md
endif
	sed -i.bu '/$(BUILD)/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(ORG)/$(NAME):$(BUILD))/' README.md

tags:
	docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" $(ORG)/$(NAME)

.PHONY: deps
deps:
	go install github.com/Shopify/sarama/tools/kafka-console-consumer@latest
	go install github.com/Shopify/sarama/tools/kafka-console-producer@latest

test: stop deps ## Test docker image
	docker rm -f kafka || true
	rm /tmp/kafka.out  || true
	docker run -d --init \
				 --name kafka \
				 -p 9092:9092 \
				 -e KAFKA_ADVERTISED_HOST_NAME=localhost \
				 -e KAFKA_CREATE_TOPICS="test-topic:1:1" $(ORG)/$(NAME):$(BUILD)
	sleep 10; kafka-console-consumer --brokers=localhost:9092 --topic=test-topic | tee -a /tmp/kafka.out &
	echo "shrinky-dinks" | kafka-console-producer --brokers=localhost:9092 --topic=test-topic
	echo "dinky-shrinks" | kafka-console-producer --brokers=localhost:9092 --topic=test-topic
	grep -q "shrinky-dinks" /tmp/kafka.out; echo $?
	rm /tmp/kafka.out || true

tar: ## Export tar of docker image
	docker save $(ORG)/$(NAME):$(BUILD) -o $(NAME).tar

push: build ## Push docker image to docker registry
	@echo "===> Pushing $(ORG)/$(NAME):$(BUILD) to docker hub..."
	@docker push $(ORG)/$(NAME):$(BUILD)

run: stop ## Run docker container
	@docker run -d --name $(NAME) -p 5044:5044 $(ORG)/$(NAME):$(BUILD)

ssh: ## SSH into docker image
	@docker run --init -it --rm --entrypoint=sh $(ORG)/$(NAME):$(BUILD)

stop: ## Kill running malice-engine docker containers
	@docker rm -f $(NAME) || true

circle: ci-size ## Get docker image size from CircleCI
	@sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell cat .circleci/SIZE)-blue/' README.md
	@echo "===> Image size is: $(shell cat .circleci/SIZE)"

ci-build:
	@echo "===> Getting CircleCI build number"
	@http https://circleci.com/api/v1.1/project/github/${REPO} | jq '.[0].build_num' > .circleci/build_num

ci-size: ci-build
	@echo "===> Getting image build size from CircleCI"
	@http "$(shell http https://circleci.com/api/v1.1/project/github/${REPO}/$(shell cat .circleci/build_num)/artifacts circle-token==${CIRCLE_TOKEN} | jq '.[].url')" > .circleci/SIZE

clean: ## Clean docker image and stop all running containers
	docker-clean stop
	docker rmi $(ORG)/$(NAME):$(BUILD) || true

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
