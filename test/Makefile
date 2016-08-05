NAME=kafka-test
ARCH=$(shell uname -m)
VERSION=0.1.0

build:
	rm -rf build
	go get -v
	go fmt
	mkdir -p build/Linux  && GOOS=linux  go build -ldflags "-X main.Version=$(VERSION)" -o build/Linux/$(NAME)
	mkdir -p build/Darwin && GOOS=darwin go build -ldflags "-X main.Version=$(VERSION)" -o build/Darwin/$(NAME)
	cp -r build /Users/user/src/github/docker-kafka-alpine/test/build

.PHONY: build
