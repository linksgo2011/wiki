---
title: Dockerfile 详解
categories: docker
toc: true
from: 《容器云运维实战》
---

## Dockerfile 编写基础

我们可以通过编写 Dockerfile 构建出 Docker 镜像，Dockerfile 可以看作为一个用于构建镜像的 Linux 命令集。Docker 在构建镜像的过程中，执行这个命令集，安装必要的软件以及一些基本的配置。

一个基本的 Dockerfle

```
FROM docker.io/nginx

COPY ./test.html /usr/share/nginx/htm/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx","-g","daemon off;"]

```

- FROM 指明基础镜像，COPY 为复制资源文件命令， CMD 为容器启动时的命令。

“Dockerfile” 是 Docker 默认的的文件名，也可使用 -f 参数进行指定其他文件名。

> docker build -t user/image:tag .
> docker build -t user/image:new -f Dockerfile.new

### Dockerfile 编写的注意事项

尽可能自动化，避免 Y/n 提示导致构建失败。

考虑命令的顺序,后面的命令会依赖前面的结果。

如果很长的命令可以使用 \&& 来进行连接,例如

```
RUN echo 'this is a long message' \
&& echo 'hello'
```

如果 Dockerfile 存放的目录还有其他文件，例如 node_modules 等超大型文件集合，Docker 也会发送到 Daemon 去构建，因此可以使用 .dockerignore 来排除文件，加快构建速度。.dockerignore 文件的语法类似于 .gitignore。

另外，一个容器最好只做一件事情，如果将数据库、前端静态页面、后端网站等都放到一个容器中，这样就失去了容器的意义。如果需要编排各种应用，可以使用 docker-compose 进行编排。

## Dockerfile 命令

### 解析器命令

解析器命令是可选的，它影响 Dockerfile 后续的处理方式。解析器命令告诉 Docker 如何处理后续的命令，使用注释的形式，写下 FROM 命令之前，否则会被作为注释处理。

目前只有一个解析命令，escape 

```
# escape=`
FROM ...
COPY testfile.txt c:\\
```

因为在 windows 下转义字符为 \ 因此 c:\\ 会被解析成 c:\

### FROM 

FORM 命令用来表明，使用那个镜像作为基础构建，一般情况下都有基础镜像。FROM 必须是 Dockerfile 的第一句命令。

> FROM <imageName:tag>

