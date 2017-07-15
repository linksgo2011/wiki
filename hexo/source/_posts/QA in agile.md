---
title: QA in agile
categories: qa
---

## 常用QA概念 ##

探索性测试:同时设计测试和执行测试。探索性测试有时候会与即兴测试（ad hoc testing）混淆。即兴测试通常是指临时准备的、即兴的Bug搜索测试过程。从定义可以看出，谁都可以做即兴测试。由Cem Kaner提出的探索性测试，相比即兴测试是一种精致的、有思想的过程。

测试金字塔: unit->service->UI, 伴随测试成本投入,收益减少。unit为测试性价比最高的方式
冒烟测试: sanity测试,快速验证应用是否能工作。
BDD测试: 基于业务的测试思想。
E2E测试: 端对端测试。
集成测试:
Functional: E2E测试。

## 常用测试工具
- selenium 可以驱动浏览器，模拟真实用户
-

## Case 设计 ##

A test case, is a set of test inputs, execution conditions, and expected results developed for a particular objective, such as to exercise a particular program path or to verify compliance with a specific requirement.

### Common Methods - Black box

- Boundary Value Analysis 边界值分析
- Equivalence Partitioning 等价划分
- Causal Diagram 因果图
- Decision Table 判定表

### Common Methods - White box

- Logical coverage
    - statement coverage
    - Branch coverage
    - Path coverage





