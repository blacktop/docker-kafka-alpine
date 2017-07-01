REPO=blacktop
NAME=kafka
BUILD ?= 0.11
LATEST ?= 0.11

all: build size test

build:
	cd $(BUILD); docker build -t $(REPO)/$(NAME):$(BUILD) .

size: build
ifeq "$(BUILD)" "$(LATEST)"
	sed -i.bu 's/docker%20image-.*-blue/docker%20image-$(shell docker images --format "{{.Size}}" $(REPO)/$(NAME):$(BUILD)| cut -d' ' -f1)-blue/' README.md
	sed -i.bu '/latest/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(REPO)/$(NAME):$(BUILD))/' README.md
endif
	sed -i.bu '/$(BUILD)/ s/[0-9.]\{3,5\}MB/$(shell docker images --format "{{.Size}}" $(REPO)/$(NAME):$(BUILD))/' README.md

tags:
	docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" $(REPO)/$(NAME)

test:
	echo "Write Tests!!!" || true

tar:
	docker save $(REPO)/$(NAME):$(BUILD) -o $(NAME).tar

run:
	docker run -d \
	           --name kafka \
	           -p 9092:9092 \
	           -e KAFKA_ADVERTISED_HOST_NAME=192.168.99.100 \
	           -e KAFKA_CREATE_TOPICS="test-topic:1:1" $(REPO)/$(NAME):$(BUILD)

clean:
	docker-clean stop
	docker rmi $(REPO)/$(NAME)
	docker rmi $(REPO)/$(NAME):$(BUILD)

.PHONY: build size tags test tar clean circle
