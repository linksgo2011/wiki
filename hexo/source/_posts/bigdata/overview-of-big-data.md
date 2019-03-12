---
title: 大数据概览
categories: bigdata
toc: true
---

大数据（big data），指无法在一定时间范围内用常规软件工具进行捕捉、管理和处理的数据集合，是需要新处理模式才能具有更强的决策力、洞察发现力和流程优化能力的海量、高增长率和多样化的信息资产。

5个维度描述大数据，Volume（大量）、Velocity（高速）、Variety（多样）、Value（低价值密度）、Veracity（真实性）

## 相关技术

- HDFS: Hadoop分布式文件系统(Distributed File System) － HDFS (Hadoop Distributed File System)
- MapReduce：并行计算框架，0.20前使用 org.apache.hadoop.mapred 旧接口，0.20版本开始引入org.apache.hadoop.mapreduce的新API
- HBase: 类似Google BigTable的分布式NoSQL列数据库。（HBase和Avro已经于2010年5月成为顶级 Apache 项目）
- Hive：数据仓库工具，由Facebook贡献。
- Zookeeper：分布式锁设施，提供类似Google Chubby的功能，由Facebook贡献。
- Avro：新的数据序列化格式与传输工具，将逐步取代Hadoop原有的IPC机制。
- Pig: 大数据分析平台，为用户提供多种接口。
- Ambari：Hadoop管理工具，可以快捷的监控、部署、管理集群。
- Sqoop：于在HADOOP与传统的数据库间进行数据的传递。