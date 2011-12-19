---
date: 2011-12-19 02:26
updated_at: <2011-12-19 02:26>
title: 集成 Hubot 和 Hudson CI
author: Terry Tai
layout: post
gallery: 2011-12-19-integrate-hubot-with-hudson-ci
comments: true
sharing: true
categories:
  - Hubot
  - CoffeeScript
  - Hudson
---

[Github]: http://github.com/
[Hubot]: http://hubot.github.com/
[Intridea]: http://intridea.com/
[Dingding]: http://twitter.com/yedingding
[Jan]: http://twitter.com/janhxie
[CoffeeScript]: http://jashkenas.github.com/coffee-script/
[Node]: http://nodejs.org/
[Hudson CI]: http://hudson-ci.org/
[Unfuddle]: http://unfuddle.com/

首先要感谢 [Github][] 创造了 [Hubot][]，而且还将其开源。我相信这样如此有趣且如此具有geek血统的东西，只有在类似 Gitbub这样充满geek文化且环境宽松的公司里才能被创造出来。

很荣幸的是我也能在 [Intridea][] 这样一个环境非常宽松且充满geeks的环境里工作。所以，在Hubot开源的第一时间，咱们的 [Dingding][] 和 [Jan][] 就各自架了自己的 ircbot 并开发了新功能，然后入住到我们平时工作的 irc channel (是的，你没有看错，我们通过irc交流，当然这包括工作和“感情”。)

他们的两个bot一个叫mm(妹妹), 一个叫gg(哥哥)。这直接造成的结果就是所有 Intridean 的员工就像全民调戏 Siri 一样，只对mm感兴趣,于是gg的新功能就被忽略了。这直接导致了我们立即merge两个bot的功能，然后只允许mm的存在。

为了更好的“调戏”mm并且提高我们的工作效率，再加上对 Hubot 以及 [CoffeeScript][]（ Hubot 是由 [CoffeeScript][] with [Node][] 写的）的好奇。我决定再为我们的mm加一个新功能。就是和我们的 [Hudson CI][] 服务器做一些集成。

主要要达到的效果是，我们能从irc里让mm就告诉我们现在 CI server 的状况。并且可以很方便通过mm触发我们的build。如图：

<!--more-->

{% img http://cl.ly/2k1h2z2y3A1X1S423Q0k/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202011-12-19%20%E4%B8%8A%E5%8D%881.54.17.png 列出项目状态 %}

{% img http://cl.ly/20433S3L203z1g0R2u1S/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202011-12-19%20%E4%B8%8A%E5%8D%881.54.44.png 出发一个build %}


代码：
--------

   要达到这样的功能我们只需要写一个新的hubot-script即可。请让我先把代码贴出来。

{% gist 1494082 %}

解释:
--------

其实代码非常简单和直观，不到一百行就实现我们需要的功能。
其中值得提到的有三点：

1. 	注释部分。其作用主要是给你这个 hubot-script 提供的命令格式和作用做一个简要说明。方便大家在irc 输入“mm: hlep”查询的时候，可以详细的列出来。

2. 写一个 hubot-script 本质上就是要实现它的 robot.respond 方法。它负责处理输入和输出，也就是解析人们给它的命令，并做出相应的返回。这里 robot.respond 就是整个hubot-script的入口。

3. 实现原理来讲，主要就是 hubot 通过 http 和 Hudson CI 服务器进行通讯。虽然 Hudson CI 的API不算强大，但是基本的功能还是有的，并且其支持json作为返回格式。整个程序其实也就用到了两个api一个是"/api/json"，其会以json的方式列出所有项目的情况。只要对json略微做一下 parse，就可以得到具体你需要的细节。还用到的一个api是 "/job/<project_name>/build", 请求相应项目的这个地址，就会触发 Hudson 对这个项目做一次 build。

总结：
--------

其实简单的一个小功能，真能提高你团队的效率。有了这个功能，我不再需要登陆到 Hudson CI 服务器的页面点来点去，去查看项目的情况或去手动点击build一个job。而且我每次的操作其他 team members 也是能从irc看到结果的。如果有了什么异常，大家也都知道。不再需要我去告诉大家需要注意。

或许这样一个小功能提高的效率还很有限，但是一个一个累积起来的方便，就不容忽视了。它会大大的提高你团队的效率。

比如，Jan 同学写的 集成 [Unfuddle][] 的功能也非常实用。我们可以不登陆那慢如蜗牛的 Unfuddle 就能在irc里查询 ticket   的情况。
又比如, Dingding 同学写的在irc里给不在线的 team members 发 email notification 的功能。也是非常的方便和有效。

上述提到的几个功能都在这里可以找到：https://github.com/janx/hubot-scripts

要不，你也试试？ :)

