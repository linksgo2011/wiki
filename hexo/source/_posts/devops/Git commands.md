---
title: 常用的GIT命令
categories: devops
toc: true
---


配置全局邮箱和名字

> git config --global user.email "email"

> git config --global user.name "name"


查看服务器和本地上分支

> git branch -a

获取服务器分支并映射到本地

> git fetch origin 远程分支名x:本地分支名x


设置pull  push映射

> git branch --set-upstream-to=origin/<branch> localBranchName



临时缓存本地更改并清空工作区

> git stash 

从 stash 中取出

> git stash pop


