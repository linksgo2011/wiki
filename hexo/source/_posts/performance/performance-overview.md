---
title: 性能优化
categories: 性能优化
toc: true
---



## 性能优化的维度

- 程序设计优化 
- Java 代码调优
- JVM 调优
- 数据库调优
- 操作系统调优

## 基准测试

- JMH Java 性能测试
- 数据性能测试



## 程序设计优化 

### 缓冲技术

缓冲技术用于协调不同系统之间的性能差异。例如文件流写入磁盘的速度慢，程序就会阻塞，缓冲像一个漏斗，先存放到内存，应用程序可以完成操作，缓冲慢慢释放内容到文件。缓冲可以大幅度提高 IO 效率。

#### BufferedWriter

用于包装 writer，构造函数的第二个参数可以指定缓冲区大小，默认为 8K。

```java
BufferedWriter bw = new BufferedWriter(new FileWriter(new File("test.txt"))) ;

bw.write("hello");
bw.write("world");

bw.flush();
bw.close();
```

#### BufferedOutputStream

用于包装输出流，构造函数的第二个参数可以指定缓冲区大小，默认为 8K。

```java
FileOutputStream fos=new FileOutputStream("test.txt");
BufferedOutputStream bos=new BufferedOutputStream(fos);
String content="hello world！";
bos.write(content.getBytes(),0,content.getBytes().length);
bos.flush();
bos.close();
```

### 缓存技术

不一定是所有从数据库读出的数据才需要缓存，很多数据都可以被缓存，例如网络请求、复杂计算，这些数据可以被零时缓存到内存中。



#### EhCache 进程内缓存

mybatis、shiro、hibernate 中的一级缓存都是 EhCache。默认内存缓存，可以配置为磁盘、外部介质。

远程 API 操作

```
// 1. 创建缓存管理器
CacheManager cacheManager = CacheManager.create("./src/main/resources/ehcache.xml");

// 2. 获取缓存对象
Cache cache = cacheManager.getCache("HelloWorldCache");

// 3. 创建元素
Element element = new Element("key1", "value1");

// 4. 将元素添加到缓存
cache.put(element);

// 5. 获取缓存
Element value = cache.get("key1");
System.out.println(value);
System.out.println(value.getObjectValue());

// 6. 删除元素
cache.remove("key1");
```

##### 使用Spring 注解操作

**@Cacheable**  

修饰的方法执行后就将返回值放入缓存，不再执行。表明所修饰的方法是可以缓存的，这个注解可以用condition属性来设置条件

```java
@Cacheable(value="UserCache", key="'user:' + #userId")    
public User findById(String userId) {    
    return (User) new User("1", "mengdee");           
}    
```

**@CacheEvict**

和 Cacheable 相反，执行后根据规则清空缓存。

```java
@CacheEvict(value="UserCache",key="'user:' + #userId")    
public void removeUser(User user) {    
    System.out.println("UserCache"+user.getUserId());    
}    
```



### 池化技术



#### 对象池

java中的对象池技术，是为了方便快捷地创建某些对象而出现的，当需要一个对象时，就可以从池中取一个出来（如果池中没有则创建一个），则在需要重复重复创建相等变量时节省了很多时间。

Java 中数据类型的包装类型支持基本的对象池技术。

#### 线程池

使用线程池可以大幅度提高多线程性能，下面是一个线程池的例子，推荐使用 Executors 创建线程：

```java
ExecutorService executor = Executors.newFixedThreadPool(10);
executor.execute(new MyThread());
executor.shutdown;
```

#### 连接池

数据库连接池使用 C3P0、DBCP、HikariCP和Druid，spring 推荐使用 DBCP，但是 Druid 支持监控，可以对慢 SQL 进行分析。


## Java 代码调优

### 字符串优化

#### 优先使用字面量，而不是 new String();

```
String str = "";
// 优于
String str1 = new String();
```

#### 优先使用 StringTokenizer 分隔字符串

#### 只用 charAt 进行字符串比较

#### 优先使用 StringBuilder 和 StringBuffer

### 合理选用数据结构

####  列表

ArrayList 通过数组实现，每次扩容会造成大量的性能消耗，适合读多写少的操作，注意设置初始数组大小。

Vector ArrayList 的线程安全实现，性能相差无几。

CopyOnWriteArray 通过 COW 技术实现线程安全的实现。

LinkedList 通过双向链表实现，查询效率低，写入速度快，适合写多读少。



#### Map

HashMap 注意设置负载因子降低冲突

LinkedHaspMap 在读取时排序，内部基于链表，适合写多读少

TreeMap 实现了 sortedMap 满足对有序性的需求，在写入时排序，内部基于红黑树，适合读多写少



####  Set

满足 Map 的无重复性需求

HashSet，对应 HashMap，基于hash的快速插入

LinkedHashSet，对应 LinkedHashMap，基于 hash 的插入，维护了插入集合的先后顺序个。按照先进先出的顺序排序

TreeSet，对应 Tree Map 基于红黑树的实现。有高效的元素 key 的排序算法



#### RandomAccess 随机访问接口

用于标记是是否支持随机访问，提高代码性能：

```
if(list isntanceof RandomAccess){
	// 随机访问
}else{
	// 老老实实使用迭代器 
}
```



### 使用 NIO 



TODO 



### 合理使用引用类型

#### 强引用

Java默认的引用方式，存在引用的情况下可以不会被回收。



#### 软引用

通过 SoftReference 使用软引用，当 内存达到一定阈值，GC会回收。



### 弱引用

GC 运行时会被回收，但是 GC 不会随时运行，因此可以利用这个特性实现某些缓存机制。

某些数据（缓存）放到一个超大的 map中会造成内存泄露，因此可以使用 WeakHashMap 来自动释放。



#### 虚引用



深入理解JAVA虚拟机一书中有这样一句描述：**“为一个对象设置虚引用关联的唯一目的就是能在这个对象被收集器回收时收到一个系统通知”。**

虚引用更多的是用于对象回收的监听。

1. 重要对象回收监听 进行日志统计
2. 系统gc监听 因为虚引用每次GC都会被回收，那么我们就可以通过虚引用来判断gc的频率，如果频率过大，内存使用可能存在问题，才导致了系统gc频繁调用



### 其他技巧



#### 少使用异常

#### 使用局部变量

局部变量在栈中，类变量在堆中。

#### 使用位运算

使用移位运算代替乘法除法（计算机实现原理）

#### 替换 switch

#### 一维数组代替二维数组

#### 使用 arrayCopy

#### 使用 Buffer 对 IO进行包装

#### 使用 clone() 代替new

clone 会绕过构造函数

#### 静态方法代替实例方法











