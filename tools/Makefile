DOCKERFILE ?= .
IMAGE_FROM ?= debian:stretch
IMAGE ?= bedrock:latest
MOUNT ?= $(shell pwd)

d_source:
	docker run --rm -it -v $(MOUNT):/shared $(IMAGE_FROM) /bin/bash

d_build:
	docker build -t $(IMAGE) $(DOCKERFILE)

d_run:
	docker run --rm -it -v $(MOUNT):/shared $(IMAGE)

d_rmi:
	docker rmi $(IMAGE)