SHELL := bash
CONTAINER_NAME := willprice/opencv4
SINGULARITY_NAME := opencv4.simg
TAG := cuda-10.1-cudnn7

.PHONY: all
all: build singularity

.PHONY: build
build:
	docker build -t $(CONTAINER_NAME):$(TAG) .

.PHONY: push
push:
	docker push $(CONTAINER_NAME):$(TAG)

.PHONY: singularity
singularity: $(SINGULARITY_NAME)

$(SINGULARITY_NAME):
	singularity build $@ Singularity
