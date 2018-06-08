---
title: API设计要点
categories: architecture
toc: true
---

Catlog

  1. 痛点分析
  2. Restful标准
      - 标准解读
      - payload
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
      -  stateless CSRF
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

