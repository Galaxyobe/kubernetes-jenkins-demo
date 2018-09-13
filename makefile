.PHONY: all var clean install-package

# environment variable
DOCKER_USERNAME ?=
DOCKER_PASSWORD ?=
## debug flag
DEBUG := false

# app
out := bin
name := app

# project
project_path := $(shell pwd)
project_name := $(notdir $(shell pwd))


# date
now := $(shell date '+%Y%m%d%I%M%S')


# git
git_branch := $(shell git symbolic-ref --short HEAD 2>/dev/null)
git_tag := $(shell git describe --abbrev=0 --tags 2>/dev/null)
git_short_commit := $(shell git rev-parse --short HEAD 2>/dev/null)


# docker
docker_registry := docker.bb-app.cn
docker_repo := demo
docker_name := ${project_name}
docker_tag_base := ${git_tag}


## docker internal
docker_registry := $(if "${docker_registry}" != "", $(addsuffix /,${docker_registry}))
docker_tag_prefix := ${docker_registry}${docker_repo}/${project_name}

## if ${git_tag} is empty use git short commit replaced
## then if git short commit use latest replaced
ifeq ($(strip ${git_short_commit}),)
	docker_tag_base := latest
else ifeq ($(strip ${git_tag}),)
	docker_tag_base := ${git_short_commit}
endif

## docker tag branch when it's not master
ifneq (${git_branch}, master)
	docker_tag_base := $(addsuffix -${git_branch},${docker_tag_base})
endif

## if git tag is not set then use latest tag as default
ifeq ($(strip $(docker_tag_base)),)
	docker_tag_base := latest
endif

## docker tags
docker_tags :=  ${docker_tag_prefix}:${docker_tag_base} \
				${docker_tag_prefix}:${docker_tag_base}-${now}


# golang

## ld flags
LDFLAGS-CROSS := -s -w
LDFLAGS-VERSION := -X main.Version=${git_tag} -X main.Date=${now} -X main.Build=${git_short_commit}
LDFLAGS := $(LDFLAGS-CROSS) $(LDFLAGS-VERSION)



# debug
debug :=

## debug flag
ifeq ($(shell echo $(DEBUG) | tr '[A-Z]' '[a-z]'), true)
	debug := @echo
endif




# default all
all: go-build docker-build 
	@echo build finish



# clean the generates
clean:
	rm -f $(out)/$(name)



# app
#
# build
$(out)/$(name): go-build

# run
run: $(out)/$(name)
	$(out)/$(name)



# install package
#
install-package: install-golang-package
	@echo all package install succeed.

# install golang package
install-golang-package: go-mod-download
	@echo golang package install succeed.



# golang
#
# go mod download
go-mod-download:
	$(debug) go mod download 

# go build
go-build: go-mod-download
	$(debug) go build -ldflags "$(LDFLAGS)" -o $(out)/$(name) .

# go run
go-run:
	$(debug) go run -ldflags "$(LDFLAGS)" *.go

# go test
go-test:
	$(debug) go test -v -cover=true



# docker
#
## docker build
docker-build: $(out)/$(name)
	$(debug) docker build $(addprefix --tag ,${docker_tags}) .

## docker login
docker-login:
ifeq ($(strip $(docker_username)),)
	$(debug) $(error You must set the docker_username environment variable)
endif
ifeq ($(strip $(docker_password)),)
	$(debug) $(error You must set the docker_password environment variable)
endif
	$(debug) docker login --username ${docker_username} --password ${docker_password} ${docker_registry}

## docker push
docker-push: docker-build docker-login
	@for tag in $(docker_tags); do \
		echo -e "\033[30;34mdocker push $${tag}\033[0m"; \
		if [ "$(debug)" == "" ]; then \
			docker push $${tag}; \
		fi \
	done;

## docker rm images
docker-rmi:
	@for tag in $(docker_tags); do \
		echo -e "\033[30;34mdocker rmi -f $${tag}\033[0m"; \
		if [ "$(debug)" == "" ]; then \
			docker rmi -f $${tag}; \
		fi \
	done;


# variable
var: 
	@echo DEBUG: ${DEBUG}
	@echo debug: ${debug}
	@echo ---
	@echo -e now: "\033[36m${now}\033[0m"
	@echo ---
	@echo project path: ${project_path}
	@echo project name: ${project_name}
	@echo ---
	@echo -e git branch: "\033[34m${git_branch}\033[0m"
	@echo -e git tag: "\033[35m${git_tag}\033[0m"
	@echo -e git short commit: "\033[36m${git_short_commit}\033[0m"
	@echo ---
	@echo docker registry: ${docker_registry}
	@echo -e docker tag base: "\033[32m${docker_tag_base}\033[0m"
	@echo docker tags: ${docker_tags}