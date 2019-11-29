---
title: Redis 基础
categories: Redis
toc: true
---

官网: https://redis.io/ 
基础教程：http://www.runoob.com/redis/redis-java.html

## 简介

Redis是一个开源的使用ANSI C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。

## 常用的数据结构

- String: 字符串
- Hash: 散列
- List: 列表
- Set: 集合
- Sorted Set: 有序集合

## cli常用操作

## 在 cli 外部批量操作

批量删除 keys

> redis-cli keys "user*" | xargs redis-cli del

## 启动 redis-server 


> redis-server 

后台运行

> redis-server --daemonize yes

后台运行也可以修改配置文件实现。



