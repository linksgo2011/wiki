---
title: Linux 虚拟机管理 Vagrant 
categories: linux
toc: true
---

## 虚拟机管理工具

在 window 上下载安装包安装即可，在 Mac 上使用 brew 安装

安装 VisualBox

> brew install caskroom/cask/virtualbox

安装 Vagrant

> brew install caskroom/cask/vagrant

可以去 http://www.vagrantbox.es/  下载 Vagrant 封装好的镜像，然后直接导入，否则自己下载镜像配置。


## 常用命令

添加虚拟机

可以在 https://app.vagrantup.com/boxes/search 上寻找和下载 virtualbox 文件

> vagrant box add centos7 /Users/nlin/www/env/centos-7.0-x86_64.box

初始化虚拟机，如果未添加虚拟机文件会自动从仓库里下载，第一次初始化会生成一个 Vagrantfile 文件用于管理素所有命令操作后的变化，利于版本管理:

> vagrant init centos7  

vagrant box add 添加时可以给一个不同的名称，用于启动多个虚拟机,这里设置一个 manager 用于 swarm manager:

> vagrant box add manager /Users/nlin/www/env/centos-7.0-x86_64.box
> vagrant init manager

启动虚拟机

> vagrant up

查看当前运行的虚拟机

> vagrant box list

进入虚拟机

> vagrant ssh

更多有用命令

> vagrant -h

## 参考资源 

- 官方文档 https://www.vagrantup.com/docs/index.html
- 安装方法 https://blog.csdn.net/yanyan42/article/details/79697659
- 一个快速上手教程 https://www.jianshu.com/p/7e8f61376053


