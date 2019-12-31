---
title: Java 各种流总结
categories: java
---

## 字节流

字节流与字符无关，可以处理所有的资源类型。

两个抽象类

- InputStream
- OutputStream

JDK 提供常用的类有

- FileInputStream
- FileOutputSteam

## 字符流

字符流需要考虑编码，只能处理文本文件。字节流变成字符流需要解码，字符流编程字节流需要编码。

两个抽象类

- Reader
- Writer 

可用的类

- FileReader
- FileWriter

## 缓冲流

缓冲流依赖字符流,拥有缓冲区机制，可以提高性能。

- BufferedReader
- BufferedWriter


## 节点流

从字节数组中创建流，使用后无需关闭。当文件不大时，可以直接读取到字节数组。

 - ByteArrayInputSteam
 - ByteArrayOutputSteam


## 处理流

- DataInputSteam 
- DataOuputSteam

## 转换流



