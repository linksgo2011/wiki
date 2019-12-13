---
title: Docker 基础 
categories: docker
toc: true
---

## 常用命令

docker pull 拉取镜像

> docker pull userxy2015/ngnix


docker images 查看所有的本地镜像

> docker images 

docker rmi 删除不必要的镜像

> docker rmi userxy2015/ngnix

docker run 启动容器

> docker run -p 8080:80 -d docker.io/nginx

docker exec 进入容器

> docker exec -it ngnix bash 

docker build 构建容器，在当前目录下加入一个 Dockerfile

```
FROM docker.io/nginx
COPY ./test.html /usr/share/nginx/htm/index.html

```

> docker build -t linksgo2011/frontend .

-t 指的是给容器打一个标签，最后的 . 指出 dockerfile的位置

docker login 登录 docker hub

> docker login 然后输入密码

docker push 推 docker 镜像到仓库，需要提前建一个 linksgo2011/frontend 仓库。https://hub.docker.com/repository

> docker push linksgo2011/frontend:latest

如果之前的镜像已经存在，可以通过 

docker tag 旧标签名 新标签名

> docker frontend linksgo2011/frontend

docker commit 将当前的容器提交为镜像，一般不常用

> docker commit c9e5bb7a524f linksgo2011/frontend


## 一些和 docker 相关的排错命令

重启 docker daemon

> sudo systemctl restart docker

## docker 文档 

https://docs.docker.com/