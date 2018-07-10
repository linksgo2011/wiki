---
title: API设计要点
categories: architecture
toc: true
---

# 细说API设计和开发

Catalog

  1. 重新认识API
  2. 理解Restful
  3. 使用JSON API置顶数据结构
      - 标准解读
      - payload
          - HATEOAS
          - 数据类型
          - 分页
          - links
          - 错误信息
            - 生产环境屏蔽信息
  4. 文档
      - swagger 
      - apidoc 
      - parade 中心化API文档管理工具
      
  5. 版本策略
      - prefix version endpoint 
      - header parameter 
      
  6. 认证和授权
      -  API和WEB的认证异同
      -  JWT
      -  OAuth
      -  终极方案，签名
  7. 性能
      -  数据节流
      -  负载均衡
          - AWS ELB 
          - Ngnix
  8. 安全
      - 幂等性下的数据一致性 
      - stateless CSRF
      - 重放工具 DDOS
      - 恶意调用
    
  9. 监控和日志
      -  dynatrace 
      -  splunk
      
  10. API测试
      -  PostMan
      -  自动化测试
          - curl
          - Python pycurl
          - newman+postman
      -  性能测试
          - AB
      -  契约测试 Pact
  11. API gateway
      - kong
      
  12. 教训
      - 版本管理优先
      - 认证优先
  13. 探索
       - Graphql
       - Firebase
     
 
如果你是一个客户端、前端开发者，你一定在某个时间吐槽过后端工程师的API设计，原因可能是文档不完善、返回数据丢字段、错误码不清晰等。
如果你是一个后端API开发者，你一定在某些时候感到困惑，怎么才能合适的描述我的API，怎么让接口URL设计的合理，数据格式怎么定，错误码怎么处理，API怎么做版本管理等问题。

在前后端分离和微服务成为现代软件开发的大趋势下，本篇希望和大家聊一些无论你听说或用过与否，你可以从中获取一些能在工作中使用API构建技术
 
我敢断言从事过互联网开发的工程师都接触过API，在我早期的工作生涯中，那时的应用是ASP、PHP等后端语言来渲染页面，往往把APIAjax联系起来，使用JavaScript调用后端的某个接口，对其中的Cookie传递、跨域限制等知识毫无意识。通过几年移动端和富前端的发展和变化，API的构建已经变得非常重要和清晰，但仍然有大量的API构建在混杂的后端应用和缺乏一些规范、完善的认证、配套的基础设施，本篇根据我近一两年俩持续工作在构建API的项目上的经验，尝试对API项目相关知识进行梳理。


## 重新认识API

- 广义的API（Application Programming Interface）是指应用程序编程接口，包括在操作系统中的动态链接库文件例如dll\so，或者基于TCP层的socket连接，用来提供预定义的方法和函数，调用者无需访问源码和理解内部原理便可实现相应功能。而当前通常指通过HTTP协议传输的web service技术。

- API在概念上和语言无关，理论上具有网络操作能力的所有编程语言都可以提供API服务。Java、PHP、Node甚至C++都可以实现web API功能，都是通过响应HTTP请求并构造HTTP包来完成的，但是内部实现原理不同。例如QQ邮箱就是通过使用了C++构建CGI服务器实现的。

- JSON和XML和API概念上无关，JSON和XML只是一种传输格式，便于计算机解析和读取数据，因此都有一个共同特点就是具有几个基本数据类型，同时提供了嵌套和列表的数据表达方式。JSON因为更加轻量、容易解析、和JavaScript天生集成，因此成为现在主流传输格式。在特殊的场景下可以构造自己的传输格式，例如JSONP传输的实际上是一段JavaScript代码来实现跨域。
- 基于以上，API设计的目的是为了让程序可读，应当遵从简单、易用、无状态等特性，这也是为什么Restful风格流行的原因。

## Restful风格和JSON API

REST（英文：Representational State Transfer，简称REST），RESTful是一种对基于HTTP的应用设计风格，只是提供了一组设计原则和约束条件，而不是一种标准，只是用来规范你的API设计变得更简洁、清晰和富有层次，对缓存等实现更有帮助。网络上有大量对RESTful风格的解读，简单来说Restful规定了如果定义URI和HTTP状态码。

Restful第一次被提出是在2000Roy Fielding的博士论文中，他也是HTTP协议标准制定者之一。从本质上理解Restful，它其实是对怎么尽可能复用HTTP特性来规范软件设计，甚至提高传输效率。HTTP包处于网络应用层，因此HTTP包为平台无关的字符串表示，如果尽可能的使用HTTP的包特征而不是大量在body定义自己的规则，可以用更简洁、清晰、高效的方式实现同样的需求。

{配图}
用我5年前一个真实的例子，我们为了提供一个订单信息API，为了更方便传递信息全部使用了POST请求

path: /base-path/product
request:
{
    "method":"getProduct",
    "data":{
       "categoryId":1,
       "productId": 1
    }
}

response:
{
    "status":"调用状态"
    "data":"数据"
    "error":"产品没找到"
    "code":"错误码"
}

对前端来说，在组装请求的时候显得麻烦不说，另外返回到数据的时候需要检查HTTP的状态是不是200，还需要检查status字段。

那么使用Restful会变成这样:


path: /base-path/categories/{categoryId}/products/{productId}
Method: GET

Status:200
response:
{
    data:{
        
    },
    error:null
}

例子中使用路径参数构建URL和HTTP状态码表示调用结果，我们能来理解Restful怎样充分利用了HTTP协议，Restful可以看做对HTTP协议上的语法（网络协议三要素：语义、语法、时序）进一步规范，因此URL通常为操作的目标实体，Method为操作的动词（GET\POST\PUT\DELETE等）,body为附带的数据。*Restful的本质是基于HTTP协议对资源的增删改查操作做出定义*


理解HTTP协议非常简单，HTTP是通过网络socket发送一段字符串，这个字符串由键值对组成的header部分和纯文本的body部分组成。Url、Cookie、Method都在header中。


几个典型的Restful API场景


|功能|URL|HTTP Method|
|获取一组数据列表|/base-path/records|GET|
|根据ID获取某个数据|/base-path/records/{recordID}|GET|
|新建数据|/base-path/records|POST|
|完整的更新数据|/base-path/records/{recordID}|PUT|
|部分更新数据|/base-path/records/{recordID}|PATCH|
|删除|/base-path/records/{recordID}|删除数据|
|跨域访问预请求|/base-path/records/{recordID}|OPTION|

虽然HTTP协议定义了其他的Method，但是就普通场景来说，用好上面的几项已经足够了


Restful的几个注意点

- 设计风格没有对错之分，Restful一种设计风格，与此对应的还有RPC甚至自定义的风格
- 无状态，HTTP设计本来就是没有状态的，之所以看起来有状态因为我们浏览器使用了cookie，每次请求都会把sessionID（可以看做身份标识）传递到headers中。关于Restful风格下怎么做用户身份认证我们会在后面讲到。
- Restful和语言、传输格式无关
- 一个典型的误区是在HTTP数据包的body部分自定义HTTP协议已经存在的规则


## Json API 

因为Restful风格仅仅规定了URL和HTTP Method的使用，这个时候你一定想问，我们怎么定义请求或者返回对象的结构，以及该如何针对不同的情况返回不同的HTTP 状态码。同样的，这个世界上已经有人注意到这个问题，有一份开源规范文档叫做jsonapi被编写出来尝试解决这个问题，jsonapi最早来源于Ember Data（Ember是一个JavaScript前端框架，在框架中定义了一个通用的数据格式，后来被广泛认可）。

JSON已经是最主流的网络传输格式，因此本文默认JSON作为传输格式来讨论后面的话题。


jsonapi尝试去提供一个非常通用的描述数据资源的格式，关于记录的创建、更新和删除，因此要求在前后端均容易实现，并包含了基本的关系类型。个人理解，它的设计非常接近数据库ORM输出的数据类型，和一些Nosql（例如MongoDB）的数据结构也很像，从而对前端开发者来说拥有操作数据库或数据集合的体验。另外一个使用这个规范的好处是，已经有大量的库和框架做了相关实现，例如，backbone-jsonapi ，json-patch。

``

## MIME 类型

JSON API数据格式已经被IANA机构接受了注册，因此必须使用application/vnd.api+json类型。客户端请求头中Content-Type应该为application/vnd.api+json，并且在Accept中也必须包含application/vnd.api+json。如果指定错误服务器应该返回415或406状态码。


## JSON文档结构


在顶级节点使用data、errors、meta，来描述数据、错误信息、元信息，注意data和errors应该互斥，不能再一个文档中同时存在。

{
  "links": {
    "self": "http://example.com/articles",
    "next": "http://example.com/articles?page[offset]=2",
    "last": "http://example.com/articles?page[offset]=10"
  },
  "data": [{
    "type": "articles",
    "id": "1",
    "attributes": {
      "title": "JSON API paints my bikeshed!"
    },
    "relationships": {
     ...
    },
    "links": {
      "self": "http://example.com/articles/1"
    }
  }],
  "included": [],
  "meta": {
    "version": "1.0",
    "copyright": "Copyright 2015 Example Corp.",
  }
}

``

### data属性

一个典型的data的对象格式

`{
     "type": "articles",
     "id": "1",
     "attributes": {
         "title": "Title for article"
      	...
     },
     "relationships": {},
     "links": {
         "self": "http://example.com/articles/1"
     }
 }

``

- id显而易见为唯一标识，可以为数字也可以为hash字符串，取决于后端实现
- type 描述数据的类型，可以对应为数据模型的类名
- attributes 代表资源的具体数据
- relationships、links为可选属性，用来放置关联数据和资源地址等数据

### errors 属性

这里的errors和data有一点不同，一般来说返回值中errors作为列表存在，因为针对每个资源可能出现多个错误信息。最典型的例子为，我们请求的对象中某些字段不符合验证要求，这里需要返回验证信息，但是HTTP状态码会使用一个通用的401，然后把具体的验证信息在errors给出来。

``

{
    "errors": [
        {
            "code": 10011,
            "title": "Name can't be null"
        },
        {
            "code": 10011,
            "title": "Content can't be null",
            "detail": ""
        }
    ]
}

``

我们可以在title字段中给出错误信息，然后在detail中给出程序堆栈信息，这让调试更为方便。需要注意的一点是，我们在生产环节需要屏蔽部分敏感信息，因此我们在生产环境屏蔽了堆栈等其它敏感的错误信息。


### 常用的返回码

返回码这部分是我开始设计API最感到迷惑的地方，如果你去查看HTTP协议文档，哪里有大量的状态码让你无从下手。实际上我们能在真实环境中用到的并不多，这里会介绍几个典型的场景。

*200 OK*
200是一个最常用的状态码，当服务器成功处理请求时返回200，例如GET请求到某一个资源，或者更新、删除某资源。需要注意的是使用POST创建资源应该返回201。


*201 Created*

如果客户端发起一个POST请求，在Restful部分我们提到，POST为创建资源，如果服务器处理成功应该返回一个创建成功的标志，在HTTP协议中，201为新建成功的状态。

文档规定，服务器必须在data中返回ID和

下面是一个HTTP的返回例子：

``

HTTP/1.1 201 Created
Location: http://example.com/photos/550e8400-e29b-41d4-a716-446655440000
Content-Type: application/vnd.api+json

{
  "data": {
    "type": "photos",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "attributes": {
      "title": "Example for relationships and links",
      "src": "http://example.com/images/productivity.png"
    },
    "links": {
      "self": "http://example.com/photos/550e8400-e29b-41d4-a716-446655440000"
    }
  }
}

``

在HTTP协议中，2XX的状态码都表示成功，还有202、204等用的较少，就不做过多介绍了，4XX返回客户端错误，会重点介绍。

* 401 *

如果服务器在检查用户输入的时候，需要传入的参数不能满足条件，服务器可以给出401错误，标记客户端错误，需要客户端自查。

*415 Unsupported Media Type*
当服务器媒体类型Content-Type和Accept指定错误的时候，应该返回415。

* 403 Forbidden *

当客户端访问未授权的资源时，服务器应该返回403要求用户授权信息。

* 404 Not Found *

这个太常见了，当指定资源找不到时服务器应当返回404。

* 500 Internal Server Error *

当服务器发生任何内部错误时，应当返回500，并给出errors字段，必要的时候需要返回错误的code，便于查错。一般来说，500错误是为了区分4XX错误，包括任何服务器内部技术或者业务异常都应该返回500。



### HATEOAS

这个时候有些同学应该会觉得上面的links和HATEOAS思想很像，那么HATEOAS是个什么呢，为什么又有一个陌生的名词要学。
实际上HATEOAS算作Restful风格的一部分，HATEOAS思想是既然Restful是利用HTTP协议来进行增删改查，那我们怎么在没有文档的情况下找到这些资源的地址呢，一种可行的办法就是在API的返回体里面加入导航信息，也就是links。这样就像HTML中的A标签实现了超文本文档一样，实现了超链接JSON文档。

超链接JSON文档是我造的一个词，它的真是名字是Hypermedia As The Engine Of Application State，中文叫做超媒体应用程序状态的引擎，网上很多讲它。但是它并不是一个很高大上的概念，在Restfu和JSONAPI部分我们都贯穿了HATEOAS思想。下面给出一个典型的例子进一步说明：

如果在某个系统中产品和订单是一对多的关系，那我们给产品的返回值可以定义为：

``

{
  "data": {
    "type": "products",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "attributes": {
      "title": "Ember Hamster",
    },
    "relationships": {
        "orders": {
          "links": {
            "self": "/base-bath/products/550e8400-e29b-41d4-a716-446655440000/orders"
          },
        }
    },
    "links": {
      "self": "/base-bath/products/550e8400-e29b-41d4-a716-446655440000"
    }
  }
}

``

从返回中我们能得到links中product的的资源地址，同时也能得到orders的地址，这样我们不需要客户端自己拼装地址，就能够得到请求orders的地址。如果我们严格按照HATEOAS开发，客户端只需要在配置文件中定义一个入口地址就能够完成所有操作，在资源地址发生变化的时候也能自动适配。

当然，在实际项目中要使用HATEOAS也要付出额外的工作量(包括开发和前后端联调)，HATEOAS只是一种思想，怎么在项目中使用也需要灵活应对了。

### 更多

在文档中还定义了分页、过滤、包含等更多内容，请移步文档：


    - 英文版：http://jsonapi.org/format/
    - 中文版：http://jsonapi.org.cn/format/ （PS：中文版更新不及时，请以英文文档为准）
    

## API文档和Mock

即使是Ajax时代，实践前后端分离最痛苦的一件事就是怎么让前后端很好的合作。我经历某些项目中甚至没有文档，前后端开发者坐到一起口口相传，后来当调用第三方API的时候用word来编写API文档。这样的方式在编写和更新的时候带来巨大的工作量，并且人工处理非常容易出错。

在工作中先后尝试使用过apidocjs、swagger等工具来实现API文档输出、Mock server、文档共享等功能。

### apidocjs

apidocjs是生成文档最轻量的一种方式，apidocjs作为npm包发布，运行在nodejs平台上。原理为解析方法前面的注释，使用方法非常类似javadoc等程序接口文档生成工具，配置和使用都非常简单。因为只是解析代码注释部分，理论上和编程语言无关。

安装：
> npm install apidoc -g


在需要输出文档的源代码中添加一个一个注释示例：

``
/**
 * @api {get} /user/:id Request User information
 * @apiName GetUser
 * @apiGroup User
 *
 * @apiParam {Number} id Users unique ID.
 *
 * @apiSuccess {String} firstname Firstname of the User.
 * @apiSuccess {String} lastname  Lastname of the User.
 */

``

最小化运行：
> apidoc -i myapp/ -o apidoc

即可在apidoc中输出静态的html文档。如果指定配置文件apidoc.json可以定义更多的操作方式，也可以自定义一套html模板用于个性化显示你的API文档，另外在输出的HTML文档中附带有API请求的测试工具，可以在我文档中尝试调用API。

使用apidocjs只需要添加几个例如@api、@apiname、@apiParam等几个必要的注释即可，值得一提是@apiDefine可以定义变量避免重复书写，@apiGroup用来对api分组，@apiVersion可以在生成不同历史的文档。

### Swagger

介绍完apidoc后，我们来认识下swagger，swagger应该是最完备的API 文档生成工具了。使用swagger能完成apidocjs提供的几乎全部功能。

Swagger有一整套关于API文档、代码生成、测试、文档共享的项目，分别是:

    - Swagger Editor 使用swagger editor编写文档定义yml文件，并生成swagger的json文件
    - Swagger UI 解析swagger的json并生成html静态文档
    - Swagger Codegen 可以通过json文档生成Java等语言里面的模板文件（模型文件）
    - Swagger Inspector Api自动化测试
    - Swagger Hub 共享swagger文档

通常我们在讨论swagger时往往说得是Swagger UI，然而Swagger UI只是提供了把文档的定义文件（json、Yaml）渲染成html静态的HTML文档，

下面我们给一个例子看怎么在Spring boot中使用swagger

我们加入依赖：

``
<dependency>
			<groupId>io.springfox</groupId>
			<artifactId>springfox-swagger-ui</artifactId>
			<version>2.2.2</version>
		</dependency>
		<dependency>
			<groupId>io.springfox</groupId>
			<artifactId>springfox-swagger2</artifactId>
			<version>2.2.2</version>
		</dependency>

``    

加入一个config文件

``
@Configuration
@EnableSwagger2
public class SwaggerConfig {                                    
    @Bean
    public Docket api() { 
        return new Docket(DocumentationType.SWAGGER_2)  
          .select()                                  
          .apis(RequestHandlerSelectors.any())              
          .paths(PathSelectors.any())                          
          .build();                                           
    }
}

``

这是我们的controller

``
@RestController
public class CustomController {
 
    @RequestMapping(value = "/custom", method = RequestMethod.POST)
    public String custom() {
        return "custom";
    }
}

``

然后访问你的context下的/context/swagger-ui.html页面，你会看到一个非常简单API文档
{配图http://www.baeldung.com/swagger-2-documentation-for-spring-rest-api}

## 使用swagger前后端协作

在过去的开发中，往往是后端开发者占主导，在前后端分离后让合作方式发生了变化。传统的方式往往是服务器开发者完成了API开发之后，前端开发者再开始共工作，在项目管理中这样产生时间线的依赖。理想的情况下，在需求明确的情况下，架构师设计，前后端应该能各自独立工作，并在最后进行集成测试即可。


前面提到了Swagger Editor，使用这个工具可以通过编写API定义文件（Yaml格式），它提供线上版本，也可以本地使用。通过生成API定义文件，就可以完成诸如生成HTML静态文档、模拟API数据等操作。



前端开发者可以通过swagger的node版本swagger-node自带的mock模式启动一个Mock server，然后根据约定模拟自己想要的数据。
关于在前端使用的mock server，实在太多，而且各有优劣，在附录中有一个清单。 


{}


后端开发者可以根据文档实现接口，最后按照文档联合调试即可。那么怎么自动化的验证我们后端的API实现是符合一定要求的呢，我会在后面的API测试部分中讲到一个叫做契约测试的方法，来保证服务器输出的API符合文档要求。

{TODO: 使用swagger的一个工作流图}

### 中心文档

在一个大型的团队中，可能会有几十个以上的项目同时提供了API，这种情况下如果每个应用都各自提供API文档就会变得很难管理，如果API文档绑定到应用服务上会带来一些无意义的损耗。

可以使用一个集中地服务来存放这些文档，类似于github的私有仓库，swagger同样也提供了类似的服务 - swaggerhub.com。


## 附录：API文档和Mock工具清单

使用或调研过的，API 文档生成工具

- apidoc
- swagger 
- blue sprint
- RAML

使用或调研过得Mock工具清单

- wiremock 
- json-server
- node-mock-server
- node-mocks-http

HTTP请求拦截器

- axios-mock-adapter
- jquery-mockjax 


## 认证 (authentication) 和授权 (authorization)

首先，认证和授权是两个不同的概念，为了让我们的API更加安全和具有清晰地权限，理解认证和授权的不同就非常有必要了。
认证和授权在英文中同样是不同的单词。

认证是authentication，指的是当前用户的身份，当用户登陆过后系统便能追踪到他的身份（cookie或token）做出符合相应业务逻辑的操作。即使用户没有登录，大多数系统也会追踪他的身份，只是当做来宾或者匿名用户来处理。

授权则不同，授权指的是什么样的身份被允许访问某些资源，在获取到用户身份后继续检查用户的权限。主流的系统中通常采用基于用户组或者基于角色的策略来设计的。

## API和WEB的认证异同

在构建API时，开发者会发现我们的认证方式和网页应用有一些不同，除了像ajax这种结合了web的技术外，我们总是强调我们的API是无状态的，Cookie便不被推荐使用。

使用Cookie的本质是用户第一次访问时服务器会分配一个Session ID，后面的请求中客户端都会带上这个ID作为当前用户的标志，因为HTTP本身是无状态的，Cookie属于一种构建于浏览器中实现状态的方式。上面我们说到API的设计是用来给客户端使用的，如果强行要求API的调用者管理Cookie也可以完成任务，但是毫无意义。

总而言之，web世界里认证的方式原理就是服务器存储一个key或者token来标识客户端每一次请求，现实中我们会见到各种自定义的实现，下面会介绍几种业界常见的做法。

### HTTP Basic Authentication

你一定用过这种方式，但不一定知道它是什么，在不久之前，当你访问一台家用路由器的管理界面，你会看到一个浏览器弹出表单，要求你输入用户密码。

在这背后，当用户输入完用户名密码后，浏览器帮你做了一个非常简单的操作

- 组合用户名和密码然后Base64编码
- 给编码后的字符串添加Basic 前缀，然后设置名称为Authorization的header头部

如果API提供HTTP Basic Authentication认证方式，那么客户端可以很简单传输用户名和密码


``java

String usernamePassword = "username:password";
String base64Credentials = new String(Base64.encodeBase64(usernamePassword.getBytes()));


``

这种方式实现起来非常简单，仍然有大量公司在一些不敏感的场景下使用，缺点也很明显。大家会觉得，Base64只能称为编码方式，而不是加密，实际上无需配置密匙的客户端并没有任何可靠地加密方式，我们都依赖SSL协议。这种方式的致命弱点是密码不会过期，一旦被盗用只能通过修改密码的方式。


### token 

鉴于上面每次请求都会带上用户名密码的做法会带来风险，并且本地会保存用户密码，通常使用另外一种做法就是签发token。

客户端操作

- 用户登录时，带上用户名和密码调用登录接口获取token
- 每一次业务请求的API都带上token，如果服务器返回token无效或者过期，要求用户重新登录

服务器

- 处理用户登录请求时，生成token并存储到数据库或缓存（推荐使用缓存，高速且自动过期）
- 处理用户业务请求时，查询token获取用户身份信息

通常来说这是一种折中的方法，在大量项目中被实践，并且各种语言提供了非常成熟的生成token的库，当我们发现用户身份异常时可以主动撤销


### JWT

上面说到token只是一段无意义的字符串，并不包含用户信息，并且每次都需要从外部存储中查找。因此有人对token做了进一步优化，设计了一种自包含令牌 - 令牌签发后无需从服务器存储中检查是否合法，通过解析令牌就能获取令牌的过期、有效等信息。
这就是JWT JSON Web Token

简而言之，一个基本的JWT令牌为一段点分3段式结构。

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ



解密后像这样

{
  'typ': 'JWT',
  'alg': 'HS256'
}
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true
}

生成JWT 令牌的流程为

- 第一部分json base64编码为令牌第一部分
- 第二部分json base64编码为令牌第二部分
- 拼装第一、第二部分编码后的json以及secret进行sha256加密为令牌的第三部分

因此只需要加密的secret就能解开JWT令牌，如果在数据中加入用户ID、过期信息就可以实现验证令牌是否有效、过期了。


#### 撤销JWT令牌

因为JWT是自包含令牌，不需要存储到数据库/缓存中，因此在使用过程中不得不考虑的一个特性就是无法被撤回。如果在某些场合使用了JWTtoken但是考虑到需要撤回，可以自己实现这部分逻辑。

目前业界最好的方案是采用一个高速key/value数据库，例如Redis，我们可以保存需要撤回的JWT token，当请求发生时，系统只在Redis中查询有效期内的令牌。因为撤回的JWT令牌只占所有的签发的令牌一小部分，以及Redis高效的索引机制，一般不会有性能上的问题。


### access key

在服务器调用API的场景下，很多服务提供了另外一种模式，对于特定的API，它的调用者可能是另外一台服务器，这就需要认证信息需要很稳定，也极少存在key丢失的情况。例如在微信公众号的开发中，应用服务器需要保存认证信息并和微信服务器进行对接。

这种情况下，API提供者可以在用户的管理dashboard中生成一个key，并且只显示一次，如果失效或丢失重新生成即可，API提供者只需要每次请求中取出key，然后在数据库或缓存中对比即可。

这种认证方式非常简单，只需要保证生成key的方式，防止撞库（Hash算法的特性，不同的输入可能产生相同的hash值）的发生就能保证安全。



### AK/SK 参数签名认证

ak=aknumber&home=world&name=hello&work=java&timestamp=now&nonce=random"


## 安全

- DDOS
- 重放攻击
- csrf攻击



