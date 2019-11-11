---
title: 敏捷开发 Way of working
categories: agile
toc: true
---

## Summary

敏捷开发流程中的一些很好的工作方式，本文中使用的敏捷方法为Scrum

## 建卡

BA负责建story卡，如果其他人需要建立卡片，需要告知BA

## three amigos

BA DEV QA 三方catchup，澄清卡的需求，然后BA移动到当前迭代

## estimation

BA发起全员来进行估算工作量，并澄清需求

估点数量按照斐波那契数列例如 1 2 3 5，超过5个点的卡需要被拆分

## ready for dev

BA把卡移动到ready for dev，然后开发就可以开始工作

## development

Dev需要和BA、QA领卡，kick off然后开始工作，每个卡需要建立一个branch，完成工作后需要检查pipeline是否通过然后，创建Pull request，然后该卡可以移动到review

## Review

Review 环节需要找人approve PR


## Ready for test

合并代码到Master，和QA sign off后移动故事卡到Ready for test
