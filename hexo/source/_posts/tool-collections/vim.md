
当前光标插入

a append 

i insert 光标前插入一行

新建一行插入
o 

% 跳转到与当前符号匹配的符号处，如(),[],{}

% 和数字 结合使用，将会跳转到文件的相应percent位置

## 复制和粘贴

[n] dd: 删除（剪切）1(n)行,这个特别好用

p 在光标之后粘贴

y 复制选中字符

H home，移动光标到文件开始位置

M Middle 移动光标到文件中部

L last 移动光标到文件末尾

查找和替换

/something: 在后面的文本中查找something。
?something: 在前面的文本中查找something。


:s/old/new - 用new替换当前行第一个old。
:s/old/new/g - 用new替换当前行所有的old。

 改变大小写
~: 反转光标所在字符的大小写。
可视模式下的U或u：把选中的文本变为大写或小写。

## do/undo
u undo
ctrl r redo


另外推荐教程：
http://vimcasts.org/
https://coolshell.cn/articles/5426.html

