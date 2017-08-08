---
title: 最实用的Linux命令
categories: linux
---

查看操作系统信息

> head -n 1 /etc/issue


install JDK8 in ubuntu 14.04

Add the webupd8 ppa, and install from that -

> sudo add-apt-repository ppa:webupd8team/java

> sudo apt-get update

> sudo apt-get install oracle-java8-installer

Then

> java -version


should show you using Oracle Java 8. If not, or if you want to use a different version - run update-java-alternatives with something like,

> sudo update-java-alternatives -s java-8-oracle

or

> sudo update-java-alternatives -s java-7-oracle

As appropriate.

Got the error: apt-get-repository Command is Missing

fixed by

> sudo apt-get update

> sudo apt-get install software-properties-common


https://stackoverflow.com/questions/25549492/install-jdk8-in-ubuntu-14-04

打包备份

> tar -zcvf "jiaonuobg_assets_$(date "+%Y%m%d").tar.gz" jiaonuobg/assets

备份nodejs+mysql项目

TBC

Maven wrapper 生成

> mvn -N io.takari:maven:wrapper
