---
title: Swarm 
categories: devops
toc: true
---

Docker 官方容器编排工具。

Docker 编排的几种模式

- Docker for desktop 
- Swarm 官方的编排工具
- K8s 社区最火的编排工具

## Swarm 相关概念

### Stack

Stack 指一个应用需要的一整套容器，例如前端、后端API、BFF等，由多个 service 构成。

### Service

一个 Service 指一个 docker compose运行后的一个服务，可以存在多个容器的副本

### Image 

一个Docker镜像

### network

容器分配的IP地址

TODO Docker 的概念

### Volumes

容器运行需要的存储空间。


 

## 参考资料

- https://docs.docker.com/v17.09/engine/swarm/