DOCKER_REGISTRY = $(AWS_ACCOUNT).dkr.ecr.$(ECR_REGION).amazonaws.com
DOCKER_PROJECT_VERSION = $(shell git tag | egrep "^v[0-9]+\.[0-9]+\.[0-9]+" | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n1 | cut -c2-)

.PHONY: help ecr_login concourse_base concourse_pgbootstrap concourse_admin concourse_worker concourse_cli publish

help:
	@echo Run \`make publish\` to proceed

ifndef AWS_ACCOUNT
$(error No AWS_ACCOUNT environment variable detected. Aborting.)
endif

ifndef DOCKER_PROJECT_VERSION
$(error No semver git tags detected. Aborting.)
endif

ifndef ECR_REGION
$(error No ECR_REGION environment variable detected. Aborting.)
endif

ecr_login:
	aws ecr get-login --region $(ECR_REGION) | sh

concourse_base: ecr_login
	docker build -t concourse-base docker-concourse/concourse-base
	docker tag concourse-base:latest $(DOCKER_REGISTRY)/concourse-base:latest
	docker push $(DOCKER_REGISTRY)/concourse-base:latest
	docker tag concourse-base:latest $(DOCKER_REGISTRY)/concourse-base:$(DOCKER_PROJECT_VERSION)
	docker push $(DOCKER_REGISTRY)/concourse-base:$(DOCKER_PROJECT_VERSION)

concourse_pgbootstrap: ecr_login
	docker build -t concourse-pgbootstrap docker-concourse/concourse-pgbootstrap
	docker tag concourse-pgbootstrap:latest $(DOCKER_REGISTRY)/concourse-pgbootstrap:latest
	docker push $(DOCKER_REGISTRY)/concourse-pgbootstrap:latest
	docker tag concourse-pgbootstrap:latest $(DOCKER_REGISTRY)/concourse-pgbootstrap:$(DOCKER_PROJECT_VERSION)
	docker push $(DOCKER_REGISTRY)/concourse-pgbootstrap:$(DOCKER_PROJECT_VERSION)

concourse_admin: ecr_login
	docker build -t concourse-admin docker-concourse/concourse-admin
	docker tag concourse-admin:latest $(DOCKER_REGISTRY)/concourse-admin:latest
	docker push $(DOCKER_REGISTRY)/concourse-admin:latest
	docker tag concourse-admin:latest $(DOCKER_REGISTRY)/concourse-admin:$(DOCKER_PROJECT_VERSION)
	docker push $(DOCKER_REGISTRY)/concourse-admin:$(DOCKER_PROJECT_VERSION)

concourse_worker: ecr_login
	docker build -t concourse-worker docker-concourse/concourse-worker
	docker tag concourse-worker:latest $(DOCKER_REGISTRY)/concourse-worker:latest
	docker push $(DOCKER_REGISTRY)/concourse-worker:latest
	docker tag concourse-worker:latest $(DOCKER_REGISTRY)/concourse-worker:$(DOCKER_PROJECT_VERSION)
	docker push $(DOCKER_REGISTRY)/concourse-worker:$(DOCKER_PROJECT_VERSION)

concourse_cli: ecr_login
	docker build -t concourse-cli docker-concourse/concourse-cli
	docker tag concourse-cli:latest $(DOCKER_REGISTRY)/concourse-cli:latest
	docker push $(DOCKER_REGISTRY)/concourse-cli:latest
	docker tag concourse-cli:latest $(DOCKER_REGISTRY)/concourse-cli:$(DOCKER_PROJECT_VERSION)
	docker push $(DOCKER_REGISTRY)/concourse-cli:$(DOCKER_PROJECT_VERSION)

publish: ecr_login concourse_base concourse_pgbootstrap concourse_admin concourse_worker concourse_cli
