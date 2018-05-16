---
title: 代码审查的注意事项
categories: engineered
toc: true
---

## 通用 TIPS

- Naming should be correct and abide by the convention
- Hard code string should be refactored as constant 
- Keep all environment consistent 
- Should not expose password and private key
- Remove useless comment and useless console statement 
- Remove any sensitive information in PROD
- Remove useless file and method 

## Review Java 

- Should not use snapshot version 
- Null should be check when try to access attribute of it
- Comparision should be use 'equal' instead of '=='
- Util methods  should be static

## Review JS 

- Eslint should be turned on 
