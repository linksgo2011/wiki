---
title: 在Ubuntu上通过apt-get搭建tomcat？
categories: java 
toc: true
---

参考博客：https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-7-on-ubuntu-14-04-via-apt-get
翻译版：http://www.linfuyan.com/how-to-install-apache-tomcat7-on-ubuntu-14-04-via-apt-get/


## 关于 Apache Tomcat

Apache Tomcat 是一个服务器应用，通常用来部署 Java 应用到 Web 。 Tomcat 是 Java Servlet 与 JSP 技术的一个开源实现，由 Apache 软件基金会发布。

这个教程涵盖了在 Ubuntu 14.04 上 Tomcat 7.0.x 版本的安装和基础配置。

有两种基本的途径来安装 Tomcat 到 Ubuntu 上：

通过 apt-get 工具来安装，这是最简单的方法。
从 Apache Tomcat 网站下载二进制发布包。本教程不涵盖这种方法。
在这个教程中，我们将使用最简单地方法： apt-get 。这将从官方的 Ubuntu 资源仓库安装最新的 Tomcat 发布包，这个包可能不是 Tomcat 的最新发布版本。如果你想要确保安装 Tomcat 的最新版，你可以下载最新的二进制发布包。

## 步骤一 - 先决条件

在你开始这个向导之前，在你的服务器上需要配置一个独立的非 root 用户账号。你可以按照 Ubuntu 14.04 上搭建服务器中的 1-4 步来学习完成它。我们这里使用创建的 demo 用户来完成后续的教程。

## 步骤二 - 安装 Tomcat

首先，你需要升级 apt-get 软件包列表：

> sudo apt-get update

现在你已经准备好安装 Tomcat。运行以下命令，开始安装：

> sudo apt-get install tomcat7

输入 yes 来安装 Tomcat 。这将同时安装 Tomcat 和它的依赖，例如 Java，同时，它将创建一个 tomcat7 用户，并以默认设置启动 Tomcat 。

这时候， Tomcat 并没有完全安装完成，但你可以通过在浏览器中输入本地域名或IP地址之后加 :8080 的方法来访问默认页面。

> http://your_ip_address:8080
你会看到一个闪屏页面，显示 “It works” ，和其他附加信息。现在，我们要深入到 Tomcat 的安装过程。

## 步骤三 - 安装额外软件包

注意：如果你对 Tomcat 足够了解，且不需要 Web 管理接口，文档和示例，那这个章节不是必须的。如果你是第一次接触 Tomcat ，请继续。

通过以下代码，你将安装 Tomcat 的在线文档， Web接 口（管理 Web 应用），以及一些示例应用。

> sudo apt-get install tomcat7-docs tomcat7-admin tomcat7-examples

## 步骤四 - 配置 Tomcat Web 管理器

想要使用步骤三中安装的 Web 应用管理器，需要先登录到 Tomcat 服务器。首先需要编辑修改 tomcat-users.xml ：

> sudo nano /etc/tomcat7/tomcat-users.xml
该文件充满了用于说明如何配置的注释。你需要删除下面两行之间的所有注释。如需要用作参考，则保留。

```

<tomcat-users>
</tomcat-users>

```
你需要添加一个用户，可以访问 manager-gui 和 admin-gui （我们在步骤三种安装的管理界面）。你可以通过如下的配置来定义一个用户。如果需要，确保修改用户名和密码。
```

<tomcat-users>
	<user username="admin" password="password" roles="manager-gui,admin-gui" />
</tomcat-users>

```

保存并退出 tomcat-users.xml 文件。重启 Tomcat 服务，以便修改配置生效。

> sudo service tomcat7 restart
