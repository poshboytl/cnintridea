---
title: 让Erlang自动编译并加载代码
author: Youcai Qian
layout: post
date: 2011-08-09 17:35
comments: true
sharing: true
categories:
  - Erlang
---

最近参与的项目使用了[ejabberd](http://ejabberd.im)，得此锲机第一次接触了[Erlang](http://erlang.org)。
作为一个函数式编程语言(functional language)，除了函数式语言本身特点之外，
因为Erlang是为分布式，高并发，高容错系统量身设计的，所以也有一些属于自己的独门秘籍。
譬如热更新(hot swapping): 系统可以在运行过程中替换部分代码，更神奇的是，新旧代码还可以部分共存。

但是，因为Erlang的相对小众，所以开发环境不是很友好。对于写惯Ruby的人来说，最痛苦的莫过于不能实时看到修改后的效果了。
不过既然Erlang有这么NB的特性，实现这样的一个效果绝对不是问题。

<!--more-->

解决方案
--------

1. 用watchr观察项目文件，一旦有文件修改保存，调用erlc编译源文件，得到beam文件
2. 拷贝并替换运行中的文件
3. 此时新代码并没有被加载，因为erlang默认并不会自动加载新文件，必须显式调用code:purge和code:load_file。

想办法自动化，google得之: [reloader.erl](https://github.com/mochi/mochiweb/blob/master/src/reloader.erl)

简单解读下这个文件：

* reloader被载入后，每一秒执行一次doit函数
* doit遍历code:all_loaded()返回的所有beam文件，如果文件发生过更新，则加载之。
* 如果有写测试的话，还会先执行下测试，测试成功后才会加载新文件

现在把reloader.erl放到项目中，重新编译安装，就可以得到一个自动加载新代码的版本了。

来一段简单的watchr脚本示例

```ruby
watch('.*\.erl') do |erl|
  puts "#{erl} is updated!"
  system("erlc #{erl}")

  beam = erl.to_s[0...-3] + "beam"
  puts "copy #{beam} to /lib/ejabberd/ebin"
  system("sudo cp #{beam} /lib/ejabberd/ebin/")
end
```

题外转发
-----------

《Programming Erlang》一书的扉页：

{% blockquote Joe Armstrong, Erlang作者 %}
The world is parallel.  

If we want to write programs that behave as other objects behave in the real
world, then these programs will have a concurrent structure.  

Use a language that was designed for writing concurrent applications, and
development becomes a lot easier.  

Erlang programs model how we think and interact.  
{% endblockquote %}

Erlang应对并行的方法

> In Erlang, processes belong to the programming language and NOT the operating system.  

> * Creating and destroying processes is very fast.
> * Sending messages between processes is very fast.
> * Processes behave the same way on all operating systems.
> * We can have very large numbers of processes.
> * Processes share no memory and are completely independent.
> * The only way for processes to interact is through message passing.

