---
title: Spring boot 源码分析
categories: Spring
toc: true
from: self
---

# 前置知识 

- 要求对 Spring 有一定了解知道 Spring 和 spring boot 之间的关系
- 对 Servlet 有一定了解
- 对类加载器有一定了解

### spring 预习

spring 本质上就是一个帮你加载类，管理类的库，所以被称作 IOC 容器。

- spring-core spring 核心基础能力：
  - 动态代理 cglib
  - 类解析 asm
  - 类实例化 objenesis
  - 基础注解  core.annotation
  - 编解码 core.codec
  - 类型转换器 core.convert
  - 配置文件解析 core.env
  - 资源读取 core.io
  - 日志 core.log
  - 序列化 core.serializer
  - 格式化输出 core.style
  - 多线程任务 core.task
  - 注解处理 core.type
  - 工具包
    - 退避算法 util.backoff
    - 比较器 util.comparator
    - 并发工具 util.concurrent
    - 单位 util.unit
    - 函数式工具 util.function
    - xml 处理工具 util.xml
  - 其他常用的工具类
    - TODO 
- spring-beans 对 bean 各种操作
  - bean 工厂 factory
  - bean 的属性编辑器
  - bean 工具
- spring-aop 实现切片编程的逻辑
- spring-expression  EL 表达式，基本实现了一个 DSL
- spring-context 整合上面的组件，提供给应用程序一个上下文容器
  - cache 缓存相关
  - context  应用上下文相关
    - annotation
    - config
    - event
    - expression
    - i18n
    - index
    - support
    - weaving
  - format
  - scheduling 计划任务
  - scripting
  - stereotype  模板类型，例如 Controller 
  - validation 数据验证

### spring boot、 spring、spring mvc 的关系

spring 是一个 IOC 容器，负责初始化对象，以及管理对象。可以看做一个库，无法作为一个应用启动。spring 实际上与 web 应用无关，但是也提供了很多 web 应用的支持。

spring boot 是一个整合了 spring 等其他技术的应用框架，开发者需要根据 spring boot 的逻辑来进行开发，spring boot 帮忙做了很多默认配置。

spring mvc  是一个响应 servlet 请求并完成请求路由映射、模型加载、视图渲染等经典 MVC 框架。



# Spring boot 启动过程

## 1 执行入口方法

```java
@SpringBootApplication
public class SpringBootBestPracticeApplication {
    public static void main(String[] args) {
        SpringApplication.run(SpringBootBestPracticeApplication.class, args);
    }
}
```

## 2 构造应用实例 new SpringApplication() 

实例化 SpringApplication 对象

```java
public static ConfigurableApplicationContext run(Class<?>[] primarySources,
      String[] args) {
   // 2. 构建应用实例
   SpringApplication app = new SpringApplication(primarySources);
   // 3. 运行应用实例
   return app.run(args);
}
```

```java
public SpringApplication(ResourceLoader resourceLoader, Class<?>... primarySources) {
   // 2.1 资源初始化资源加载器为 null
   this.resourceLoader = resourceLoader;
   Assert.notNull(primarySources, "PrimarySources must not be null");
   this.primarySources = new LinkedHashSet<>(Arrays.asList(primarySources));
   // 2.2 推断当前 WEB 应用类型,判断是一个 webflux 还是普通 servlet 项目，或者不是 web 项目
   this.webApplicationType = WebApplicationType.deduceFromClasspath();
   // 2.3 设置应用上下文初始化器 ,ApplicationContextInitializer 接口负责在项目启动时候初始话各种资源，这里支持不同的初始化器，例如加载配置文件、注册属性资源、激活 Profiles 
  setInitializers((Collection) getSpringFactoriesInstances(
         ApplicationContextInitializer.class));
   // 2.4 设置监听器
   setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
   // 2.5 推断主入口应用类
   this.mainApplicationClass = deduceMainApplicationClass();
}
```



### 2.1 资源初始化资源加载器为 null

### 2.2 推断应用类型

```java
static WebApplicationType deduceFromClasspath() {
   if (ClassUtils.isPresent(WEBFLUX_INDICATOR_CLASS, null)
         && !ClassUtils.isPresent(WEBMVC_INDICATOR_CLASS, null)
         && !ClassUtils.isPresent(JERSEY_INDICATOR_CLASS, null)) {
      return WebApplicationType.REACTIVE;
   }
   for (String className : SERVLET_INDICATOR_CLASSES) {
      if (!ClassUtils.isPresent(className, null)) {
         return WebApplicationType.NONE;
      }
   }
   return WebApplicationType.SERVLET;
}
```

ClassUtils.isPresent 检测 org.springframework.web.reactive.DispatcherHandler 这个类是否存在，并且没有加载 Spring mvc 以及 Jersey 可以判定为 REACTIVE 模式。

如果没有加载任何 ConfigurableWebApplicationContext 相关的类，判定为非 web 项目。



### 2.3 构造 SpringApplication  的上下文初始化器

获取初始化器的实例

```java
private <T> Collection<T> getSpringFactoriesInstances(Class<T> type,
      Class<?>[] parameterTypes, Object... args) {
   // 2.3.1 通过 SpringFactoriesLoader.loadFactoryNames 加载该接口的所有实现
   ClassLoader classLoader = getClassLoader();
   // 2.3.2 通过 SpringFactoriesLoader.loadFactoryNames 加载该接口的所有实现
   Set<String> names = new LinkedHashSet<>(
         SpringFactoriesLoader.loadFactoryNames(type, classLoader));
   // 2.3.3 使用 BeanUtils.instantiateClass 实例化所有的类
   List<T> instances = createSpringFactoriesInstances(type, parameterTypes,
         classLoader, args, names);
   // 2.3.4 使用 BeanUtils.instantiateClass 使用注解比较器进行排序
   AnnotationAwareOrderComparator.sort(instances);
   return instances;
}
```



#### 2.3.1 获取 class loader 

```java
if (this.resourceLoader != null) {
   return this.resourceLoader.getClassLoader();
}
return ClassUtils.getDefaultClassLoader();
```



ClassUtils 的实现原理为 Thread.currentThread().getContextClassLoader();  并做了回退处理

- Thread.currentThread().getContextClassLoader(); 
- ClassUtils.class.getClassLoader();
- ClassLoader.getSystemClassLoader();



#### 2.3.2 加载初始化类名

```java
		public static List<String> loadFactoryNames(Class<?> factoryClass, @Nullable ClassLoader classLoader) {
		String factoryClassName = factoryClass.getName();
		return loadSpringFactories(classLoader).getOrDefault(factoryClassName, Collections.emptyList());
	}
```

```java
private static Map<String, List<String>> loadSpringFactories(@Nullable ClassLoader classLoader) {
   MultiValueMap<String, String> result = cache.get(classLoader);
   if (result != null) {
      return result;
   }

   try {
      Enumeration<URL> urls = (classLoader != null ?
            classLoader.getResources(FACTORIES_RESOURCE_LOCATION) :
            ClassLoader.getSystemResources(FACTORIES_RESOURCE_LOCATION));
      result = new LinkedMultiValueMap<>();
      while (urls.hasMoreElements()) {
         URL url = urls.nextElement();
         UrlResource resource = new UrlResource(url);
         Properties properties = PropertiesLoaderUtils.loadProperties(resource);
         for (Map.Entry<?, ?> entry : properties.entrySet()) {
            String factoryClassName = ((String) entry.getKey()).trim();
            for (String factoryName : StringUtils.commaDelimitedListToStringArray((String) entry.getValue())) {
               result.add(factoryClassName, factoryName.trim());
            }
         }
      }
      cache.put(classLoader, result);
      return result;
   }
   catch (IOException ex) {
      throw new IllegalArgumentException("Unable to load factories from location [" +
            FACTORIES_RESOURCE_LOCATION + "]", ex);
   }
}
```

基本原理是通过 class loader 找到 META-INF/spring.factories 文件解析并获取 `ApplicationContextInitializer` 接口的所有配置的类路径名称。

这里非常关键，spring boot 通过加载不同的 ApplicationContextInitializer 对上下文进行初始化，这是 spring boot 应用具有大量特性的同时也能保持灵活性的重要手段。

urls 是类加载器以及双亲委派模式下的类加载器加载出来的所有资源，然后遍历获取需要的类。

ApplicationContextInitializer 的类定义有几个潜在来源：

- spring boot 本身提供了4 个类
- devtools 提供了1个用于热加载后刷新上下文的类
- autoconfigure 提供了2个用于自动配置的类

我加载了 devtools 因此加载了7个上下文初始化类。

```
0 = "org.springframework.boot.devtools.restart.RestartScopeInitializer"
1 = "org.springframework.boot.autoconfigure.SharedMetadataReaderFactoryContextInitializer"
2 = "org.springframework.boot.autoconfigure.logging.ConditionEvaluationReportLoggingListener"
3 = "org.springframework.boot.context.ConfigurationWarningsApplicationContextInitializer"
4 = "org.springframework.boot.context.ContextIdApplicationContextInitializer"
5 = "org.springframework.boot.context.config.DelegatingApplicationContextInitializer"
6 = "org.springframework.boot.web.context.ServerPortInfoApplicationContextInitializer"
```

这里使用了一个 LinkedMultiValueMap 数据结构，可以为一个 key 存储多个值，构建出一个树类似的结构，便于解析 properties 文件。

可以把从不同的 spring.factories 中的代码块汇集到一个对象中，一个 spring.factories 数据结构如下

```
# Error Reporters
org.springframework.boot.SpringBootExceptionReporter=\
org.springframework.boot.diagnostics.FailureAnalyzers

# Application Context Initializers
org.springframework.context.ApplicationContextInitializer=\
org.springframework.boot.context.ConfigurationWarningsApplicationContextInitializer,\
org.springframework.boot.context.ContextIdApplicationContextInitializer,\
org.springframework.boot.context.config.DelegatingApplicationContextInitializer,\
org.springframework.boot.web.context.ServerPortInfoApplicationContextInitializer
```

如果有多个 jar 包中都有 ApplicationContextInitializer配置块，通过LinkedMultiValueMap 可以很方便的合并同样key的集合。

#### 2.3.3 实例化初始化器类

```java
@SuppressWarnings("unchecked")
private <T> List<T> createSpringFactoriesInstances(Class<T> type,
      Class<?>[] parameterTypes, ClassLoader classLoader, Object[] args,
      Set<String> names) {
   List<T> instances = new ArrayList<>(names.size());
   for (String name : names) {
      try {
         Class<?> instanceClass = ClassUtils.forName(name, classLoader);
         Assert.isAssignable(type, instanceClass);
         Constructor<?> constructor = instanceClass
               .getDeclaredConstructor(parameterTypes);
         T instance = (T) BeanUtils.instantiateClass(constructor, args);
         instances.add(instance);
      }
      catch (Throwable ex) {
         throw new IllegalArgumentException(
               "Cannot instantiate " + type + " : " + name, ex);
      }
   }
   return instances;
}
```



#### 2.3.4 使用注解比较器进行排序



```java
public static void sort(List<?> list) {
   if (list.size() > 1) {
      list.sort(INSTANCE);
   }
}
```

INSTANCE 是 AnnotationAwareOrderComparator 的一个单例，继承 OrderComparator 实现通过顺序进行比较。AnnotationAwareOrderComparator 的职责是通过找到 Order 注解进行排序。



### 2.4 设置监听器

获取监听器的原理和上下文初始化器一样，不过类型换成了 ApplicationListener。

```properties
# Application Listeners
org.springframework.context.ApplicationListener=\
org.springframework.boot.ClearCachesApplicationListener,\
org.springframework.boot.builder.ParentContextCloserApplicationListener,\
org.springframework.boot.context.FileEncodingApplicationListener,\
org.springframework.boot.context.config.AnsiOutputApplicationListener,\
org.springframework.boot.context.config.ConfigFileApplicationListener,\
org.springframework.boot.context.config.DelegatingApplicationListener,\
org.springframework.boot.context.logging.ClasspathLoggingApplicationListener,\
org.springframework.boot.context.logging.LoggingApplicationListener,\
org.springframework.boot.liquibase.LiquibaseServiceLocatorApplicationListener
```

### 2.5 推断主入口应用类

```java
private Class<?> deduceMainApplicationClass() {
   try {
      StackTraceElement[] stackTrace = new RuntimeException().getStackTrace();
      for (StackTraceElement stackTraceElement : stackTrace) {
         if ("main".equals(stackTraceElement.getMethodName())) {
            return Class.forName(stackTraceElement.getClassName());
         }
      }
   }
   catch (ClassNotFoundException ex) {
      // Swallow and continue
   }
   return null;
}
```

通过构造一个运行时异常，再遍历异常栈中的方法名，获取方法名为 main 的栈帧，从来得到入口类的名字再返回该类。



应用程序的主入口 Spring boot 并不知道，通过模拟一个异常栈，根据异常栈中的元素找出 main 方法，通过这种方式获取入口应用类。



## 3 运行应用实例

上面分析了创建 SpringApplication 实例的过程，下面分析实例创建后是如何被启动的。



```java
public ConfigurableApplicationContext run(String... args) {
   // 3.1 创建并启动计时监控类
   StopWatch stopWatch = new StopWatch();
   stopWatch.start();
   // 初始化应用上下文和异常报告集合
   ConfigurableApplicationContext context = null;
   Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
   // 3.2 设置系统属性 `java.awt.headless` 的值，默认值为：true
   configureHeadlessProperty();
   // 3.3 创建所有 Spring 运行监听器并发布应用启动事件
   SpringApplicationRunListeners listeners = getRunListeners(args);
   listeners.starting();
  
   try {
      // 3.4 初始化默认应用参数类
      ApplicationArguments applicationArguments = new DefaultApplicationArguments(
            args);
      // 3.5 根据运行监听器和应用参数来准备 Spring 环境
      ConfigurableEnvironment environment = prepareEnvironment(listeners,
            applicationArguments);
      // 根据 spring.beaninfo.ignore 配置忽略 bean
      configureIgnoreBeanInfo(environment);
      // 3.6 创建 Banner 打印类 
      Banner printedBanner = printBanner(environment);
      
      // 3.7 创建应用上下文
      context = createApplicationContext();
      
      // 准备异常报告器
      exceptionReporters = getSpringFactoriesInstances(
            SpringBootExceptionReporter.class,
            new Class[] { ConfigurableApplicationContext.class }, context);
     
      // 3.8 准备应用上下文
      prepareContext(context, environment, listeners, applicationArguments,
            printedBanner);
      // 3.9 刷新应用上下文
      refreshContext(context);
      
      // 3.10 应用上下文刷新后置处理
      afterRefresh(context, applicationArguments);

     	// 3.11 停止计时监控类
      stopWatch.stop();
      // 3.12 输出日志记录执行主类名、时间信息
      if (this.logStartupInfo) {
         new StartupInfoLogger(this.mainApplicationClass)
               .logStarted(getApplicationLog(), stopWatch);
      }
     
      // 3.13 发布应用上下文启动完成事件
      listeners.started(context);
     
      // 3.14 执行所有 Runner 运行器
      callRunners(context, applicationArguments);
   }
   catch (Throwable ex) {
      handleRunFailure(context, ex, exceptionReporters, listeners);
      throw new IllegalStateException(ex);
   }

   try {
      // 3.15 发布应用上下文就绪事件
      listeners.running(context);
   }
   catch (Throwable ex) {
      // 3.16 处理运行异常
      handleRunFailure(context, ex, exceptionReporters, null);
      throw new IllegalStateException(ex);
   }
   return context;
}
```



### 3.1 创建并启动计时监控类

```java
StopWatch stopWatch = new StopWatch();
stopWatch.start();
```

StopWatch 的源码

```java
public void start() throws IllegalStateException {
    start("");
}

public void start(String taskName) throws IllegalStateException {
    if (this.currentTaskName != null) {
        throw new IllegalStateException("Can't start StopWatch: it's already running");
    }
    this.currentTaskName = taskName;
    this.startTimeMillis = System.currentTimeMillis();
}
```

首先记录了当前任务的名称，默认为空字符串，然后记录当前 Spring Boot 应用启动的开始时间。

### 3.2 设置系统属性 `java.awt.headless` 

```java
private void configureHeadlessProperty() {
   System.setProperty(SYSTEM_PROPERTY_JAVA_AWT_HEADLESS, System.getProperty(
         SYSTEM_PROPERTY_JAVA_AWT_HEADLESS, Boolean.toString(this.headless)));
}
```



设置变量 `Java.awt.headless = true` 

>Java包含很多类，这些类假设有某种显示和一个附加的键盘。有时，你写的代码运行在一个没有这些的服务器上，这被称为无头模式。有时，你写的代码运行在一个没有这些的服务器上，这被称为无头模式。从Java 1.4开始，您就可以明确地告诉Java以Headless模式运行。
>
>https://stackoverflow.com/questions/2552371/setting-java-awt-headless-true-programmatically



### 3.3 创建所有 Spring 运行监听器并发布应用启动事件



```java
private SpringApplicationRunListeners getRunListeners(String[] args) {
   Class<?>[] types = new Class<?>[] { SpringApplication.class, String[].class };
   return new SpringApplicationRunListeners(logger, getSpringFactoriesInstances(
         SpringApplicationRunListener.class, types, this, args));
}
```

创建逻辑和之前实例化初始化器和监听器的一样，一样调用的是 `getSpringFactoriesInstances` 方法来获取配置的监听器名称并实例化所有的类。

```properties
# Run Listeners
org.springframework.boot.SpringApplicationRunListener=\
org.springframework.boot.context.event.EventPublishingRunListener
```



### 3.4 初始化默认应用参数类

```java
ApplicationArguments applicationArguments = new DefaultApplicationArguments(
      args);
```

只是用一个类 DefaultApplicationArguments  包装了一下参数输入。

### 3.5 根据应用参数来准备环境

```java
ConfigurableEnvironment environment = prepareEnvironment(listeners,
      applicationArguments);
```

```java
private ConfigurableEnvironment prepareEnvironment(
      SpringApplicationRunListeners listeners,
      ApplicationArguments applicationArguments) {
   // Create and configure the environment
   // 3.5.1 获取或者创建应用环境
   ConfigurableEnvironment environment = getOrCreateEnvironment();
   // 3.5.2 配置应用环境
   configureEnvironment(environment, applicationArguments.getSourceArgs());
   // 发布事件
   listeners.environmentPrepared(environment);
   // 3.5.3 绑定环境
   bindToSpringApplication(environment);
   if (!this.isCustomEnvironment) {
     // 3.5.4 自定义环境转换
      environment = new EnvironmentConverter(getClassLoader())
            .convertEnvironmentIfNecessary(environment, deduceEnvironmentClass());
   }
   // 3.5.5 附加配置属性
   ConfigurationPropertySources.attach(environment);
   return environment;
}
```



#### 3.5.1 获取或者创建应用环境



```java
private ConfigurableEnvironment getOrCreateEnvironment() {
   if (this.environment != null) {
      return this.environment;
   }
   switch (this.webApplicationType) {
   case SERVLET:
      return new StandardServletEnvironment();
   case REACTIVE:
      return new StandardReactiveWebEnvironment();
   default:
      return new StandardEnvironment();
   }
}
```



根据应用类型的不同，存在3种实现:

- StandardServletEnvironment
- StandardReactiveWebEnvironment 
- StandardEnvironment 

StandardServletEnvironment、StandardReactiveWebEnvironment 都是继承于 StandardEnvironment，用于管理系统环境变量以及配置文件。



Environment 对象就是存放我们设置的 profile 信息，默认为 default。





#### 3.5.2 配置应用环境

```java
configureEnvironment(environment, applicationArguments.getSourceArgs());
```

使用刚刚创建的环境对象管理环境参数。

```java
protected void configureEnvironment(ConfigurableEnvironment environment,
      String[] args) {
   // 3.5.2.1 配置转换服务
   if (this.addConversionService) {
      ConversionService conversionService = ApplicationConversionService
            .getSharedInstance();
      environment.setConversionService(
            (ConfigurableConversionService) conversionService);
   }
   // 3.5.2.2 配置属性资源
   configurePropertySources(environment, args);
   // 3.5.2.3 配置 profiles
   configureProfiles(environment, args);
}
```

##### 3.5.2.1 配置转换服务

addConversionService 默认为 true，提供一个数据类型转换服务。在配置文件中大多是使用字符串，帮我们转换成容易使用的数据类型，例如 duration 这类的配置可以被转换成数值。

getSharedInstance() 是一个单例实现，用于组合各种数据类型的转换器、文本解析器，可以学习一下。

```java
public static ConversionService getSharedInstance() {
   ApplicationConversionService sharedInstance = ApplicationConversionService.sharedInstance;
   if (sharedInstance == null) {
      synchronized (ApplicationConversionService.class) {
         sharedInstance = ApplicationConversionService.sharedInstance;
         if (sharedInstance == null) {
            sharedInstance = new ApplicationConversionService();
            ApplicationConversionService.sharedInstance = sharedInstance;
         }
      }
   }
   return sharedInstance;
}
```

ApplicationConversionService 注册了大量的转换器，确保配置被合理的转换成特定的数据类型。

```java
public static void addApplicationConverters(ConverterRegistry registry) {
   addDelimitedStringConverters(registry);
   registry.addConverter(new StringToDurationConverter());
   registry.addConverter(new DurationToStringConverter());
   registry.addConverter(new NumberToDurationConverter());
   registry.addConverter(new DurationToNumberConverter());
   registry.addConverter(new StringToDataSizeConverter());
   registry.addConverter(new NumberToDataSizeConverter());
   registry.addConverterFactory(new StringToEnumIgnoringCaseConverterFactory());
}
```

addDelimitedStringConverters 中包含了大量逗号分隔符的转换器，用于将逗号分隔的字符串转换成集合。

```java
public static void addDelimitedStringConverters(ConverterRegistry registry) {
   ConversionService service = (ConversionService) registry;
   registry.addConverter(new ArrayToDelimitedStringConverter(service));
   registry.addConverter(new CollectionToDelimitedStringConverter(service));
   registry.addConverter(new DelimitedStringToArrayConverter(service));
   registry.addConverter(new DelimitedStringToCollectionConverter(service));
}

```

有一些专门的解析和生成字符串类的格式化器，具有格式化成字符串、解析字符串的能力。

```java
public static void addApplicationFormatters(FormatterRegistry registry) {
   registry.addFormatter(new CharArrayFormatter());
   registry.addFormatter(new InetAddressFormatter());
   registry.addFormatter(new IsoOffsetFormatter());
}
```

转换器和格式化器继承的父类和实现的接口不太一样。

![image-20200405145057079](spring-boot-workflow/image-20200405145057079.png)

<center>（转换器）<center>
![image-20200405145258465](spring-boot-workflow/image-20200405145258465.png)

<center>(格式化器)</center>

##### 3.5.2.2 配置属性资源

```java
protected void configurePropertySources(ConfigurableEnvironment environment,
      String[] args) {
   MutablePropertySources sources = environment.getPropertySources();
   if (this.defaultProperties != null && !this.defaultProperties.isEmpty()) {
      sources.addLast(
            new MapPropertySource("defaultProperties", this.defaultProperties));
   }
   if (this.addCommandLineProperties && args.length > 0) {
      String name = CommandLinePropertySource.COMMAND_LINE_PROPERTY_SOURCE_NAME;
      if (sources.contains(name)) {
         PropertySource<?> source = sources.get(name);
         CompositePropertySource composite = new CompositePropertySource(name);
         composite.addPropertySource(new SimpleCommandLinePropertySource(
               "springApplicationCommandLineArgs", args));
         composite.addPropertySource(source);
         sources.replace(name, composite);
      }
      else {
         sources.addFirst(new SimpleCommandLinePropertySource(args));
      }
   }
}
```



这里将命令行中的配置添加到，配置列表中，因为 spring boot 支持各种各样的配置来源，因此需要做大量类似的工作。这里根据命令行参数添加了 `SimpleCommandLinePropertySource`配置来源。

参考 https://docs.spring.io/spring-boot/docs/2.2.6.RELEASE/reference/htmlsingle/#boot-features-external-config

##### 3.5.2.3 配置 profiles

```java
protected void configureProfiles(ConfigurableEnvironment environment, String[] args) {
   environment.getActiveProfiles(); // ensure they are initialized
   // But these ones should go first (last wins in a property key clash)
   Set<String> profiles = new LinkedHashSet<>(this.additionalProfiles);
   profiles.addAll(Arrays.asList(environment.getActiveProfiles()));
   environment.setActiveProfiles(StringUtils.toStringArray(profiles));
}
```

通过获取到的 profiles 信息，设置当前激活的 profiles。

#### 3.5.3 绑定配置信息到对象上

```java
protected void bindToSpringApplication(ConfigurableEnvironment environment) {
   try {
      Binder.get(environment).bind("spring.main", Bindable.ofInstance(this));
   }
   catch (Exception ex) {
      throw new IllegalStateException("Cannot bind to SpringApplication", ex);
   }
}
```

pringboot 2.x新引入的类，负责处理对象与多个 ConfigurationPropertySource（属性）之间的绑定，可以将多个配置属性绑定到类的属性上，这里面的内容比较复杂，不再过深入展开。

#### 3.5.4 自定义环境转换

```java
if (!this.isCustomEnvironment) {
   environment = new EnvironmentConverter(getClassLoader())
         .convertEnvironmentIfNecessary(environment, deduceEnvironmentClass());
}
```

如果在最开始传入的 environment 对象不是 deduceEnvironmentClass() 中的三种之一，那么需要转换，默认为关闭状态。

```java
private Class<? extends StandardEnvironment> deduceEnvironmentClass() {
   switch (this.webApplicationType) {
   case SERVLET:
      return StandardServletEnvironment.class;
   case REACTIVE:
      return StandardReactiveWebEnvironment.class;
   default:
      return StandardEnvironment.class;
   }
}
```

#### 3.5.5 附加配置属性

```java
public static void attach(Environment environment) {
   Assert.isInstanceOf(ConfigurableEnvironment.class, environment);
   MutablePropertySources sources = ((ConfigurableEnvironment) environment)
         .getPropertySources();
   PropertySource<?> attached = sources.get(ATTACHED_PROPERTY_SOURCE_NAME);
   if (attached != null && attached.getSource() != sources) {
      sources.remove(ATTACHED_PROPERTY_SOURCE_NAME);
      attached = null;
   }
   if (attached == null) {
      sources.addFirst(new ConfigurationPropertySourcesPropertySource(
            ATTACHED_PROPERTY_SOURCE_NAME,
            new SpringConfigurationPropertySources(sources)));
   }
}
```

TODO 这段代码还不知道干嘛用的，尤其是 SpringConfigurationPropertySources 这个类

### 3.6 创建 Banner 打印类 

```java
private Banner printBanner(ConfigurableEnvironment environment) {
   if (this.bannerMode == Banner.Mode.OFF) {
      return null;
   }
   ResourceLoader resourceLoader = (this.resourceLoader != null)
         ? this.resourceLoader : new DefaultResourceLoader(getClassLoader());
   SpringApplicationBannerPrinter bannerPrinter = new SpringApplicationBannerPrinter(
         resourceLoader, this.banner);
   if (this.bannerMode == Mode.LOG) {
      return bannerPrinter.print(environment, this.mainApplicationClass, logger);
   }
   return bannerPrinter.print(environment, this.mainApplicationClass, System.out);
}
```

打印一个 banner 信息，基本的逻辑就是 SpringApplicationBannerPrinter 类根据配置文件在指定的位置打印出 banner，根据 banner 输出的模式分为日志、控制台、不打印。

### 3.7 创建应用上下文[核心点]

```java
protected ConfigurableApplicationContext createApplicationContext() {
   Class<?> contextClass = this.applicationContextClass;
   if (contextClass == null) {
      try {
         switch (this.webApplicationType) {
         case SERVLET:
            contextClass = Class.forName(DEFAULT_SERVLET_WEB_CONTEXT_CLASS);
            break;
         case REACTIVE:
            contextClass = Class.forName(DEFAULT_REACTIVE_WEB_CONTEXT_CLASS);
            break;
         default:
            contextClass = Class.forName(DEFAULT_CONTEXT_CLASS);
         }
      }
      catch (ClassNotFoundException ex) {
         throw new IllegalStateException(
               "Unable create a default ApplicationContext, "
                     + "please specify an ApplicationContextClass",
               ex);
      }
   }
   return (ConfigurableApplicationContext) BeanUtils.instantiateClass(contextClass);
}
```

非常关键的一个环节，初始化一个 Spring boot 上下文，在这个上下文中会启动 Spring 上下文，实际上在这之前还没有启动 Spring 。根据不同的应用类型初始不同的上下文，如果是一个普通 web 应用，默认初始化的是  `AnnotationConfigServletWebServerApplicationContext` 。

使用 BeanUtils.instantiateClass 来初始化一个类，这种初始化方法能使用 Spring 类的生命周期注解。这里默认构造了一个上下文，通过这个上下文在后面利用 spring 初始化 bean 的时候非常重要。

基本上这个类是 Spring boot 继承于 Spring 中的 ServletWebServerApplicationContext，ServletWebServerApplicationContext 有继承于 GenericApplicationContext。GenericApplicationContext 是一个抽象程度非常高的上下文。实现了大量与应用类型无关的 bean 操作，后面的 bean 初始化会靠它，另外一个很重要的是 这里默认初始花了一个 DefaultListableBeanFactory 作为 bean 工厂。



![image-20200405225010409](spring-boot-workflow/image-20200405225010409.png)



### 3.8 准备应用上下文

```java
private void prepareContext(ConfigurableApplicationContext context,
      ConfigurableEnvironment environment, SpringApplicationRunListeners listeners,
      ApplicationArguments applicationArguments, Banner printedBanner) {
   // 设置环境信息
   context.setEnvironment(environment);
   // 3.8.1 配置 bean 生成器和资源加载器
   postProcessApplicationContext(context);
   // 3.8.2 应用所有的初始化器 
   applyInitializers(context);
   // 上下文准备完成通知
   listeners.contextPrepared(context);
   // 3.8.3 记录启动日志
   if (this.logStartupInfo) {
      logStartupInfo(context.getParent() == null);
      logStartupProfileInfo(context);
   }
   // 3.8.4 注册两个特殊的 bean 
   ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
   beanFactory.registerSingleton("springApplicationArguments", applicationArguments);
   if (printedBanner != null) {
      beanFactory.registerSingleton("springBootBanner", printedBanner);
   }
   if (beanFactory instanceof DefaultListableBeanFactory) {
      ((DefaultListableBeanFactory) beanFactory)
            .setAllowBeanDefinitionOverriding(this.allowBeanDefinitionOverriding);
   }
   // 3.8.5 加载所有的资源 
   Set<Object> sources = getAllSources();
   Assert.notEmpty(sources, "Sources must not be empty");
   load(context, sources.toArray(new Object[0]));
   // 通知上下文加载完成
   listeners.contextLoaded(context);
}
```

#### 3.8.1 配置 bean 生成器和资源加载器

```java
protected void postProcessApplicationContext(ConfigurableApplicationContext context) {
   if (this.beanNameGenerator != null) {
      context.getBeanFactory().registerSingleton(
            AnnotationConfigUtils.CONFIGURATION_BEAN_NAME_GENERATOR,
            this.beanNameGenerator);
   }
   if (this.resourceLoader != null) {
      if (context instanceof GenericApplicationContext) {
         ((GenericApplicationContext) context)
               .setResourceLoader(this.resourceLoader);
      }
      if (context instanceof DefaultResourceLoader) {
         ((DefaultResourceLoader) context)
               .setClassLoader(this.resourceLoader.getClassLoader());
      }
   }
   if (this.addConversionService) {
      context.getBeanFactory().setConversionService(
            ApplicationConversionService.getSharedInstance());
   }
}
```

#### 3.8.2 应用所有的初始化器 

```java
protected void applyInitializers(ConfigurableApplicationContext context) {
   for (ApplicationContextInitializer initializer : getInitializers()) {
      Class<?> requiredType = GenericTypeResolver.resolveTypeArgument(
            initializer.getClass(), ApplicationContextInitializer.class);
      Assert.isInstanceOf(requiredType, context, "Unable to call initializer.");
      initializer.initialize(context);
   }
}
```



这一步会把所有符合条件的 ApplicationContextInitializer 应用一遍，实际上 spring boot 的主要启动过程都在这几个 ApplicationContextInitializer 中。

前面讲过，spring boot 是如何将需要的类加载进来，这里需要说明下几个主要的初始化器的功能。

我在调试时主要有这几个：

```
org.springframework.boot.devtools.restart.RestartScopeInitializer
org.springframework.boot.autoconfigure.SharedMetadataReaderFactoryContextInitializer
org.springframework.boot.autoconfigure.logging.ConditionEvaluationReportLoggingListener
org.springframework.boot.context.ConfigurationWarningsApplicationContextInitializer
org.springframework.boot.context.ContextIdApplicationContextInitializer
org.springframework.boot.context.config.DelegatingApplicationContextInitializer
org.springframework.boot.web.context.ServerPortInfoApplicationContextInitializer
```

**RestartScopeInitializer**

主要是注册了一个 restart 的 bean scope 用热重载。

```java
public void initialize(ConfigurableApplicationContext applicationContext) {
   applicationContext.getBeanFactory().registerScope("restart", new RestartScope());
}
```

在 RestartScope 中使用了 Restarter 来刷新应用。

TODO 

#### 3.8.3 记录启动日志



创建了一个日志类，将日志打出

```java
new StartupInfoLogger(this.mainApplicationClass)
      .logStarting(getApplicationLog());
```

```java
public void logStarting(Log log) {
   Assert.notNull(log, "Log must not be null");
   if (log.isInfoEnabled()) {
      log.info(getStartupMessage());
   }
   if (log.isDebugEnabled()) {
      log.debug(getRunningMessage());
   }
}
```

 先判断日志是否开启 `log.isInfoEnabled`() 是为了提高性能，如果开启 info 会打出启动信息。只有开启 debug 级别的日志，才会打出运行时信息。

```
logStartupProfileInfo(context);
```

接下来打印 profile 的日志信息，如果没有设置 profile，也就是会显示我们平时看到的 

> No active profile set, falling back to default profiles: default



#### 3.8.4 注册两个特殊的 bean 

 

```java
ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
beanFactory.registerSingleton("springApplicationArguments", applicationArguments);
if (printedBanner != null) {
   beanFactory.registerSingleton("springBootBanner", printedBanner);
}
if (beanFactory instanceof DefaultListableBeanFactory) {
   ((DefaultListableBeanFactory) beanFactory)
         .setAllowBeanDefinitionOverriding(this.allowBeanDefinitionOverriding);
}
```



这里将当前使用到的  `applicationArguments` 和 `springBootBanner`  注册成单例，用于后面需要的时候获取。通过这种方式附加到上下文中。

#### 3.8.5 加载所有的资源 (包扫描)

```java
		// 3.8.5.1 加载包扫描资源类
    Set<Object> sources = getAllSources();
		Assert.notEmpty(sources, "Sources must not be empty");
    // 3.8.5.2 包扫描
		load(context, sources.toArray(new Object[0]));
		listeners.contextLoaded(context);
```

##### 3.8.5.1 加载包扫描资源类

```java
public Set<Object> getAllSources() {
   Set<Object> allSources = new LinkedHashSet<>();
   if (!CollectionUtils.isEmpty(this.primarySources)) {
      allSources.addAll(this.primarySources);
   }
   if (!CollectionUtils.isEmpty(this.sources)) {
      allSources.addAll(this.sources);
   }
   return Collections.unmodifiableSet(allSources);
}
```

˙这里的 primarySources 就是指的 run 方法传入的类，spring boot 会根据资源类所在的包进行扫描。加载各种业务对象。因此可以在入口类中，可以做一些拓展，主动加载其他资源，甚至远程资源。

##### 3.8.5.2 包扫描

```java 
protected void load(ApplicationContext context, Object[] sources) {
   if (logger.isDebugEnabled()) {
      logger.debug(
            "Loading source " + StringUtils.arrayToCommaDelimitedString(sources));
   }
   // 初始化 bean 加载器
   BeanDefinitionLoader loader = createBeanDefinitionLoader(
         getBeanDefinitionRegistry(context), sources);
   if (this.beanNameGenerator != null) {
      loader.setBeanNameGenerator(this.beanNameGenerator);
   }
   if (this.resourceLoader != null) {
      loader.setResourceLoader(this.resourceLoader);
   }
   if (this.environment != null) {
      loader.setEnvironment(this.environment);
   }
   // 最终的初始化类的地方
   loader.load();
}

// 下面调用了 BeanDefinitionLoader 的构造方法
protected BeanDefinitionLoader createBeanDefinitionLoader(
      BeanDefinitionRegistry registry, Object[] sources) {
   return new BeanDefinitionLoader(registry, sources);
}
```

```java
 // BeanDefinitionLoader 实际上是一个简单的外观模式，包装了 Spring 中初始化 bean 的常用方法
 BeanDefinitionLoader(BeanDefinitionRegistry registry, Object... sources) {
		Assert.notNull(registry, "Registry must not be null");
		Assert.notEmpty(sources, "Sources must not be empty");
		this.sources = sources;
    // 基于注解的 bean 阅读器
		this.annotatedReader = new AnnotatedBeanDefinitionReader(registry);
		this.xmlReader = new XmlBeanDefinitionReader(registry);
		if (isGroovyPresent()) {
			this.groovyReader = new GroovyBeanDefinitionReader(registry);
		}
    // 类扫描器
		this.scanner = new ClassPathBeanDefinitionScanner(registry);
		this.scanner.addExcludeFilter(new ClassExcludeFilter(sources));
	}
```

这里就是 spring boot 利用 spring 初始化各种类的核心了。通过 BeanDefinitionLoader 包装 spring 中的 bean 实例化工具，初始化各种对象。

当所有的准备工作做完后，通过调用 loader.load(); 初始化各种 bean 。



```java
// 多资源加载
public int load() {
   int count = 0;
   for (Object source : this.sources) {
      count += load(source);
   }
   return count;
}

// 某个资源，一般这个资源是根目录下的一个类，例如 Application.class 但是 Spring 也是支持各种加载方式。
private int load(Object source) {
   Assert.notNull(source, "Source must not be null");
   // 一般都会走这里
   if (source instanceof Class<?>) {
      return load((Class<?>) source);
   }
   if (source instanceof Resource) {
      return load((Resource) source);
   }
   if (source instanceof Package) {
      return load((Package) source);
   }
   if (source instanceof CharSequence) {
      return load((CharSequence) source);
   }
   throw new IllegalArgumentException("Invalid source type " + source.getClass());
}


private int load(Class<?> source) {
		if (isGroovyPresent()
				&& GroovyBeanDefinitionSource.class.isAssignableFrom(source)) {
			// Any GroovyLoaders added in beans{} DSL can contribute beans here
			GroovyBeanDefinitionSource loader = BeanUtils.instantiateClass(source,
					GroovyBeanDefinitionSource.class);
			load(loader);
		}
		if (isComponent(source)) {
			this.annotatedReader.register(source);
			return 1;
		}
		return 0;
}
```

isComponent 是用来排除匿名类等特殊情况，一般来说都会为 true，然后进入 

```java
this.annotatedReader.register(source);
```

到了这里就已经是 Spring 的地盘了，spring boot 的工作完成了，交给 spring 去初始化各种对象了。

### 3.9 刷新应用上下文 [spring 核心]

```java
protected void refresh(ApplicationContext applicationContext) {
   Assert.isInstanceOf(AbstractApplicationContext.class, applicationContext);
   ((AbstractApplicationContext) applicationContext).refresh();
}
```

spring boot 把 context 作为 applicationContext 传入，然后转换成 AbstractApplicationContext 调用 spring 的refresh() 开启 bean 初始化的流程。

spring 的 refresh 实际上就是初始化 bean，为什么是 refresh()，而不是 init()，这个名字非常奇怪。实际上，spring 的 refresh 不仅仅对新的 context 有用，对旧的 context 会销毁重建，因此 refresh 这个词更适中。

```java
@Override
public void refresh() throws BeansException, IllegalStateException {
   // 加锁，防止多次启动或者销毁操作造成混乱
   synchronized (this.startupShutdownMonitor) {
      // 3.9.1 准备刷新，记录启动时间、状态
      prepareRefresh();

      // 3.9.2 提取 bean 的配置
      ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

      // 3.9.3 为当前 context 做准备
      prepareBeanFactory(beanFactory);

      try {
         // 3.9.4 后置处理
         postProcessBeanFactory(beanFactory);

         // 3.9.5 调用 postProcessBeanFactory
         invokeBeanFactoryPostProcessors(beanFactory);

         // 3.9.6 注册 BeanPostProcessor 的实现类
         registerBeanPostProcessors(beanFactory);

         // 3.9.7 初始化国际化消息
         initMessageSource();

         // 3.9.8 初始化事件广播器
         initApplicationEventMulticaster();

         // 为子类设计的钩子方法
         onRefresh();

         // 注册监听器
         registerListeners();

         // 3.9.9 初始化所有的 singleton beans
         finishBeanFactoryInitialization(beanFactory);

         // 广播事件
         finishRefresh();
      }

      catch (BeansException ex) {
         if (logger.isWarnEnabled()) {
            logger.warn("Exception encountered during context initialization - " +
                  "cancelling refresh attempt: " + ex);
         }

         // 3.9.10 销毁已经初始化的 singleton 的 Beans 
         destroyBeans();

         // 设置初始话状态
         cancelRefresh(ex);

         // 往外丢异常
         throw ex;
      }

      finally {
         // 3.9.11 清理构建过程中的对象缓存
         resetCommonCaches();
      }
   }
}
```

这部分就是 spring 容器初始化的核心逻辑了，spring 更多细节可以查看其他材料。

推荐材料：https://www.javadoop.com/post/spring-ioc



##### 3.9.1 准备刷新，记录启动时间、状态

```java
protected void prepareRefresh() {
   // 设置状态和时间
   this.startupDate = System.currentTimeMillis();
   this.closed.set(false);
   this.active.set(true);

   if (logger.isDebugEnabled()) {
      if (logger.isTraceEnabled()) {
         logger.trace("Refreshing " + this);
      }
      else {
         logger.debug("Refreshing " + getDisplayName());
      }
   }

   // 空方法，留给子类初始化配置
   initPropertySources();

   // 验证必要的属性
   getEnvironment().validateRequiredProperties();

   // 将 applicationListeners 用 earlyApplicationListeners 包裹起来
   if (this.earlyApplicationListeners == null) {
      this.earlyApplicationListeners = new LinkedHashSet<>(this.applicationListeners);
   }
   else {
      this.applicationListeners.clear();
      this.applicationListeners.addAll(this.earlyApplicationListeners);
   }
   this.earlyApplicationEvents = new LinkedHashSet<>();
```

##### 3.9.2 提取 bean 的配置

```java
protected ConfigurableListableBeanFactory obtainFreshBeanFactory() {
   // 关闭旧的 BeanFactory 重新加载 bean 信息
   refreshBeanFactory();

   // 返回刚刚创建的 BeanFactory
   ConfigurableListableBeanFactory beanFactory = getBeanFactory();
   if (logger.isDebugEnabled()) {
      logger.debug("Bean factory for " + getDisplayName() + ": " + beanFactory);
   }
   return beanFactory;
}
```

##### 3.9.3 为当前 context 做准备
##### 3.9.4 后置处理
##### 3.9.5 调用 postProcessBeanFactory
##### 3.9.6 注册 BeanPostProcessor 的实现类
##### 3.9.7 初始化国际化消息
##### 3.9.8 初始化事件广播器
##### 3.9.9 初始化所有的 singleton beans
##### 3.9.10 销毁已经初始化的 singleton 的 Beans 
##### 3.9.11 清理构建过程中的对象缓存



### 3.10 应用上下文刷新后置处理

### 3.11 停止计时监控类

### 3.12 输出日志记录执行主类名、时间信息

### 3.13 发布应用上下文启动完成事件

### 3.14 执行所有 Runner 运行器

### 3.15 发布应用上下文就绪事件

### 3.16 处理运行异常





# Spring mvc 响应请求过程



# Spring boot 打包流程