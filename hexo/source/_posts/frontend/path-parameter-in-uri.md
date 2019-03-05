---
title: 处理URL中path参数
categories: fronted
toc: true
---


```
export function paramsPath(pathString, ...params) {
  let result = pathString
  params.forEach((value) => {
    result = result.replace(/\:\w+/, value)
  })
  return result
}

```