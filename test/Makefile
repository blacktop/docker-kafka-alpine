NAME=kafka-test
ARCH=$(shell uname -m)
VERSION=0.1.0

build:
	rm -rf build
	go get -v
	go fmt
	mkdir -p build/linux  && GOOS=linux  go build -ldflags "-X main.Version=$(VERSION)" -o build/linux/$(NAME)
	mkdir -p build/darwin && GOOS=darwin go build -ldflags "-X main.Version=$(VERSION)" -o build/darwin/$(NAME)

.PHONY: build
