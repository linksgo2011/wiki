---
title: spring data
categories: Spring
---


## 查询方法策略

查询方法策略就是Spring Data如何从 repository 中找到合适的查询方法。有一下几种

- CREATE 尝试从查询方法名称构造特定于仓库的查询。例如 findByName，根据约定有以下几种查询方式：
    -  find…By
    -  read…By
    -  query…By
    -  count…By
    -  get…By
- USE_DECLARED_QUERY 会从 repository 中定义的方法中寻找合适的查询方式
- CREATE_IF_NOT_FOUND 这是 JPA 默认的策略，组合CREATE和USE_DECLARED_QUERY


CREATE 策略的几个例子：

```
interface PersonRepository extends Repository<User, Long> {

  List<Person> findByEmailAddressAndLastname(EmailAddress emailAddress, String lastname);

  // Enables the distinct flag for the query
  List<Person> findDistinctPeopleByLastnameOrFirstname(String lastname, String firstname);
  List<Person> findPeopleDistinctByLastnameOrFirstname(String lastname, String firstname);

  // Enabling ignoring case for an individual property
  List<Person> findByLastnameIgnoreCase(String lastname);
  // Enabling ignoring case for all suitable properties
  List<Person> findByLastnameAndFirstnameAllIgnoreCase(String lastname, String firstname);

  // Enabling static ORDER BY for a query
  List<Person> findByLastnameOrderByFirstnameAsc(String lastname);
  List<Person> findByLastnameOrderByFirstnameDesc(String lastname);
}
```

- 表达式通常是属性遍历和可以连接的运算符。您可以使用组合属性表达式AND和OR。您还可以得到这样的运营商为支撑Between，LessThan，GreaterThan，和Like该属性的表达式。受支持的操作员可能因数据存储而异，因此请参阅相应部分的参考文档。

- 方法解析器支持IgnoreCase为单个属性（例如，findByLastnameIgnoreCase(…)）或支持忽略大小写的类型的所有属性（通常为String实例 - 例如findByLastnameAndFirstnameAllIgnoreCase(…)）设置标志。支持忽略情况的方式可能因商店而异，因此请参阅参考文档中的相关部分以获取特定于商店的查询方法。

- 您可以通过OrderBy向引用属性的查询方法附加子句并提供排序方向（Asc或Desc）来应用静态排序。

分页的情况
```
Page<User> findByLastname(String lastname, Pageable pageable);

Slice<User> findByLastname(String lastname, Pageable pageable);

List<User> findByLastname(String lastname, Sort sort);

List<User> findByLastname(String lastname, Pageable pageable);

```

## 参考资料

-  Spring data  中文版本 https://blog.csdn.net/yongboyhood/article/details/81226553
-  JPA 教程 https://www.yiibai.com/jpa/jpa-introduction.html

