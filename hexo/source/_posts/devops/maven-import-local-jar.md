---
title: Maven 将本地 jar 大包到项目
categories: java
toc: true
---

## 使用 install 到本地仓库的方案

使用 mvn install 到本地，如果使用 CI 可以先于 mvn package 执行。

```
mvn install:install-file \
   -Dfile=<path-to-file> \
   -DgroupId=<group-id> \
   -DartifactId=<artifact-id> \
   -Dversion=<version> \
   -Dpackaging=<packaging> \
   -DgeneratePom=true
```

然后按照正常的方式引入依赖即可。

## 其他方案

systemPath 方式导入，但是这种方式，测试和本地运行可以，服务器运行会报找不到 class 的错误。

```
<dependency>
    <groupId>com.sample</groupId>
    <artifactId>sample</artifactId>
    <version>1.0</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/src/main/resources/Name_Your_JAR.jar</systemPath>
</dependency>
```