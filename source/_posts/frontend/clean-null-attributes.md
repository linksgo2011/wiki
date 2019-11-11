---
title: 清理对象中的空值
categories: frontend
toc:true
--- 

```
/**
 * 清理对象中的空值
 * @param object
 */
export function cleanNullAttributes(object) {
  const returnValue = {}
  Object.keys(object).map(key => {
    const value = object[key]
    if (value === undefined || value === null || value === '') {
      return
    }
    returnValue[key] = value
    return key
  })

  return returnValue
}

```