---
title: Java unmodifiableMap
categories: Java
---


集合中提供了一个防止修改的方法

```
public final Map<Foo, Bar> getMap(){
    ...
    return Collections.unmodifiableMap(map);
}

```
