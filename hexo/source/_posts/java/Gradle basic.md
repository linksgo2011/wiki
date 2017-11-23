---
title: Gradle 使用基础
categories: java
---

## 介绍

Gradle 是一个打包工具和Maven一样能构建java项目。和前端类比的打包工具是Grunt等


## 基本原理

Gradle创建的工程由 Project和Tasks，Gradle所有的任务都是通过引入插件和编写task来实现的

## 常用配置

`

buildscript {
	ext {
		springBootVersion = '1.5.6.RELEASE'
	}
	repositories {
		mavenCentral()
	}
	dependencies {
		classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")
	}
}

apply plugin: 'java'
apply plugin: 'eclipse'
apply plugin: 'org.springframework.boot'

version = '0.0.1-SNAPSHOT'
sourceCompatibility = 1.8

repositories {
	mavenCentral()
}


dependencies {

	compile('org.springframework.boot:spring-boot-starter-web')
	compile group: 'org.springframework.boot', name: 'spring-boot-starter-data-jpa', version: '1.5.3.RELEASE'
	compile group: 'javax.servlet.jsp.jstl', name: 'javax.servlet.jsp.jstl-api', version: '1.2.1'
	compile group: 'org.apache.tomcat.embed', name: 'tomcat-embed-jasper', version: '9.0.0.M25'
	compile group: 'javax.servlet', name: 'jstl', version: '1.2'
	compile group: 'org.glassfish', name: 'javax.el', version: '3.0.0'
	compile group: 'org.apache.commons', name: 'commons-lang3', version: '3.0'

	runtime('mysql:mysql-connector-java')

	testCompile('org.springframework.boot:spring-boot-starter-test')
}

`

## 常用命令

查看所有的任务列表

> gradle tasks --all



