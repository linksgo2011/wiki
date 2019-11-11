---
title: 实用的SQL语句技巧
categories: mysql
---
使用SQL完成文本替换操作

> update typecho_contents set text=REPLACE (addr,'http://bcs.duapp.com/helpjs','http://helpjs.bj.bcebos.com/')

表之间复制数据,可以使用 select into table1(field1,field2) select (value1,value2) from table2

>  insert into user_temp(id,phone_nbr,open_id,project_from,task_id)
           select id,phone_nbr,open_id,project_from,task_id from user where task_id=#{taskId}
