---
title: API设计要点
categories: architecture
toc: true
---

# 细说API设计和开发

Catalog

  1. 重新认识API
  2. Restful
      - 标准解读
      - payload
          - HATEOAS
          - 数据类型
          - 分页
          - links
          - 错误信息
            - 生产环境屏蔽信息
  3. 文档
      - swagger 
      - apidoc 
      - parade 中心化API文档管理工具
      
  4. 版本策略
      - prefix version endpoint 
      - header parameter 
  5. 认证和授权
      -  API和WEB的认证异同
      -  JWT
      -  OAuth
      -  终极方案，签名
  6. 性能
      -  数据节流
      -  负载均衡
          - AWS ELB 
          - Ngnix
  7. 安全
      - 幂等性下的数据一致性 
      - stateless CSRF
      -  DDOS 
      -  
  8. 监控
      -  dynatrace 
      -  splunk
  9. API测试
      -  PostMan
      -  自动化测试
          - curl
          - Python pycurl
          - newman+postman
      -  性能测试
          - AB
      -  契约测试 Pact
  10. API gateway
      - kong
      
  11. 教训
      - 版本管理优先
      - 认证优先
  12. 探索
       - Graphql
       - Firebase
     
 
如果你是一个客户端、前端开发者，你一定在某个时间吐槽过后端工程师的API设计，原因可能是文档不完善、返回数据丢字段、错误码不清晰等。
如果你是一个后端API开发者，你一定在某些时候感到困惑，怎么才能合适的描述我的API，怎么让接口URL设计的合理，数据格式怎么定，错误码怎么处理，API怎么做版本管理等问题。

在前后端分离和微服务成为现代软件开发的大趋势下，本篇希望和大家聊一些无论你听说或用过与否，你可以从中获取一些能在工作中使用API构建技术
 
我敢断言从事过互联网开发的工程师都接触过API，在我早期的工作生涯中，那时的应用是ASP、PHP等后端语言来渲染页面，往往把APIAjax联系起来，使用JavaScript调用后端的某个接口，对其中的Cookie传递、跨域限制等知识毫无意识。通过几年移动端和富前端的发展和变化，API的构建已经变得非常重要和清晰，但仍然有大量的API构建在混杂的后端应用和缺乏一些规范、完善的认证、配套的基础设施，本篇根据我近一两年俩持续工作在构建API的项目上的经验，尝试对API项目相关知识进行梳理。
 

## 重新认识API

- 广义的API（Application Programming Interface）是指应用程序编程接口，包括在操作系统中的动态链接库文件例如dll\so，或者基于TCP层的socket连接，用来提供预定义的方法和函数，调用者无需访问源码和理解内部原理便可实现相应功能。而当前通常指通过HTTP协议传输的web service技术。

- API在概念上和语言无关，理论上具有网络操作能力的所有编程语言都可以提供API服务。Java、PHP、Node甚至C++都可以实现web API功能，都是通过响应HTTP请求并构造HTTP包来完成的，但是内部实现原理不同。例如QQ邮箱就是通过使用了C++构建CGI服务器实现的。

- JSON和XML和API概念上无关，JSON和XML只是一种传输格式，便于计算机解析和读取数据，因此都有一个共同特点就是具有几个基本数据类型，同时提供了嵌套和列表的数据表达方式。在特殊的场景下可以构造自己的传输格式，例如JSONP传输的实际上是一段JavaScript代码来实现跨域。
- 基于以上，API设计的目的是为了让程序可读，应当遵从简单、易用、无状态等特性，这也是为什么Restful风格流行的原因。

## 理解Restful风格




