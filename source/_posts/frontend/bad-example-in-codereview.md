---
title: 前端代码的一些反模式
categories: frontend
toc: true
---


## 大量无意义的注释

```

    // 获取所有软件列表
    getSoftList () {
      this.cacheAllSoftList = require('./db.json').agents
      this.allSoftList = this.cacheAllSoftList
    },
    // 选择类型
    clickTab (obj) {
      this.activeTab = obj.value
    },
    // 选择布局
    clickLayout (obj) {
      this.activeLayout = obj.value
    },
    // 添加resource
    onSubmit (item) {
      item.resources.push(this.addResourceForm.name)
    },
    // 删除resource
    deleteResource (item, index) {
      item.resources.splice(index, 1)
    }

```



