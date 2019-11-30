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

|类型|简介|特性|场景|
|--|--|--|--|
| String | 二进制安全 | 可以包含任何数据,比如jpg图片或者序列化的对象,一个键最大能存储512M |	---|
| Hash | 键值对集合,即编程语言中的Map类型 | 适合存储对象,并且可以像数据库中update一个属性一样只修改某一项属性值(Memcached中需要取出整个字符串反序列化成对象修改完再序列化存回去) | 存储、读取、修改用户属性 |
| List | 链表(双向链表) | 增删快,提供了操作某一段元素的API	 | 1,最新消息排行等功能(比如朋友圈的时间线) 2,消息队列 |
| Set | 哈希表实现,元素不重复 | 1、添加、删除,查找的复杂度都是O(1) 2、为集合提供了求交集、并集、差集等操作 | 1、共同好友 2、利用唯一性,统计访问网站的所有独立ip 3、好友推荐时,根据tag求交集,大于某个阈值就可以推荐 | 
| Sorted Set | 将Set中的元素增加一个权重参数score,元素按score有序排列 | 数据插入集合时,已经进行天然排序 | 1、排行榜 2、带权重的消息队列|


## cli常用操作

## 在 cli 外部批量操作

批量删除 keys

> redis-cli keys "user*" | xargs redis-cli del

## 启动 redis-server 


> redis-server 

后台运行

> redis-server --daemonize yes

后台运行也可以修改配置文件实现。



