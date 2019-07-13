---
title: JPA 批量插入数据
categories: java
---

```

@Override
    @Transactional
    public <S extends T> Iterable<S> batchSave(Iterable<S> var1) {
        Iterator<S> iterator = var1.iterator();
        int index = 0;
        while (iterator.hasNext()){
            em.persist(iterator.next());
            index++;
            if (index % BATCH_SIZE == 0){
                em.flush();
                em.clear();
            }
        }
        if (index % BATCH_SIZE != 0){
            em.flush();
            em.clear();
        }
        return var1;
    }

```

在application.properties,设置spring.jpa.properties.hibernate.jdbc.batch_size
在application.properties,设置spring.jpa.properties.hibernate.generate_statistics（只是为了检查批处理是否正常）
在application.properties设置JDBC URL中rewriteBatchedStatements=true （特定于MySQL的优化）
在application.properties设置 JDBC URL中使用cachePrepStmts=true（启用缓存，如果您决定设置prepStmtCacheSize，  则也很有用  prepStmtCacheSqlLimit;等等;如果没有此设置，则禁用缓存）
在application.properties设置 JDBC URL中useServerPrepStmts=true（通过这种方式切换到服务器端预处理语句（可能会显着提升性能））
在实体中，使用指定的生成器，  因为MySQL IDENTITY将导致批处理被禁用
在DAO中，不时刷新并清除持久性上下文。这样，您就可以避免“压跨”持久化上下文。

作者：Java高级架构狮
链接：https://www.jianshu.com/p/ae08c18fcb37
来源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。