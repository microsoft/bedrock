DOCKERFILE ?= .
IMAGE_FROM ?= debian:stretch
IMAGE ?= bedrock:v0.12.0
MOUNT ?= $(shell pwd)

d_source:
	docker run --rm -it -v $(MOUNT):/shared $(IMAGE_FROM) bash

d_build:
	docker build -t $(IMAGE) $(DOCKERFILE)

d_run:
	docker run --rm -it -v $(MOUNT):/shared $(IMAGE) bash

d_rmi:
	docker rmi $(IMAGE)