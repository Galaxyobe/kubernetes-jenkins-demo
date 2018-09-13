# kubernetes-jenkins-demo

- [kubernetes]
- [jenkins]
- [docker]

## Makefile

### Install

- go-dep

    > make install-go-dep

### Golang

- dep

    > make go-dep

- test

    > make go-test

- build

    > make go-build

- run

    > make go-run

### Docker

- build

    dependent on: go-build

    > make docker-build

- login

    > make docker-login DOCKER_USERNAME=(docker registry username) DOCKER_PASSWORD=(docker registry password)

- push:

    dependent on: docker-login

    > make docker-push

### Debug

- enabled debug

    > make DEBUG=true ...

- print variable

    > make var

### clean

- clean

    > make clean

## Docker image

### variable

1. docker registry: docker.bb-app.cn

2. docker repo: demo

3. docker image name: kubernetes-jenkins-demo

4. build date: 20180907174830 (e.g.)

5. git branch: master dev (e.g.)

6. git short commit: 254b411 (e.g.)

7. git tag: v0.1.0 (e.g.)
    if it's empty use git short commit replaced,
    then if git short commit use latest replaced

### image name and tag

- master branch

    * docker.bb-app.cn/demo/kubernetes-jenkins-demo:v0.1.0

    * docker.bb-app.cn/demo/kubernetes-jenkins-demo:v0.1.0-20180907174830

- not master branch, e.g.: dev

    * docker.bb-app.cn/demo/kubernetes-jenkins-demo:v0.1.0-dev

    * docker.bb-app.cn/demo/kubernetes-jenkins-demo:v0.1.0-dev-20180907174830