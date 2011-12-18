---
title: Refactormycode.com 升级了!
author: Andy Wang
layout: post
date: 2011-07-06 17:35
comments: true
sharing: true
categories:
  - Refactor 
  - Rails
  - Work
  - OpenSource
---

{% img https://img.skitch.com/20110628-x8pwpuuba4dmkg4kr4fdf9xua5.jpg RefactorMyCode.com %}

大概两年以前，有一次我搜索一个和RubyOnRails有关的技术问题，无意间发现了一个有趣的技交流社区[RefactorMyCode.com](http://refactormycode.com)。出于好奇和对Refactor精神的认同，我在这个网站上面注册了一个用户，来回搜索一番之后，我彻底喜欢上这个网站，我喜欢它鼓励分享编程技巧和促使程序员学习他人编程经验的方式。

三个月以前，我加入[Intridea](http://intridea.com)成为它的一员，Intridea是一个伟大和开放的公司，她鼓励每个人都利用自己的业余时间参与一些自己感兴趣的项目，在Intridea我们称之为SparkTime Project。当我决定在已有的所有SparkTime项目中挑选一个自己感兴趣的项目的时候，我意外的发现**RefactorMyCode**也在其中，这让我感到兴奋，于是我毫不犹豫的选择了这个项目的维护和更新。更重要的是，我可以亲自参与进这个项目，来弘扬Refactor精神。

我有一个同事（[Jon](http://intridea.com/about/people/jonbishop)）两个月以前曾经在一篇[博文](http://intridea.com/2011/4/18/-refactormycode-lives-on-open-source-coming-soon)中介绍过RefactorMyCode这个项目，我个人很感激它的原作者将这个项目交给Intridea来维护和更新。这个项目在交接的时候，是基于**Rails2.0.2**和**Ruby1.8.7**运行的，相对与Rails的版本更新速度，这个项目的Rails版本可谓OUT很多，因次，我打算先将其升级到**Rails3.0**。然后，我们还打算开源这个项目，以便得到根多人的关注和鼓励更多人参与进来。

<!-- more -->

RefactorMyCode最近有什么变化?
-----------------------------

很显然，将该项目从Rails2.0.2升级到Rails3有点麻烦，毕竟这两个版本之间间隔了将近两年的时间，Rails在这两个版本之间也发生了很多变化，我所面临的主要问题是修改一些**routes**和**ajax**请求，在这里用到了一个插件[rails_upgrade](https://github.com/jm/rails_upgrade)，如果你也有类似的升级需求，这个插件会有帮助。同时，我们也很顺利的将网站从Ruby1.8.7升级到Ruby1.9.2.

在我们的情况中，我将一些复杂的ajax请求改写为直接请求，从而使请求更为直观，也提高了Refactor的效率，稍后会再增加一些必要的ajax效果，以增加用户的使用体验;同时我移除了[will_paginate](https://github.com/mislav/will_paginate)这个插件，[kaminari](https://github.com/amatsuda/kaminari)是完美的可以替代**will_paginate**的分页方案;类似的Refactor还包括基于[acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)对标签系统的更新和基于[Albino](https://github.com/github/albino)对语法高亮功能的重写。

最后一点Refactor很重要，那就是利用[omniauth](https://github.com/intridea/omniauth)对现有的登录验证系统进行了重构，[omniauth](https://github.com/intridea/omniauth)是我们公司开发的一个优秀的Auth插件，目前最新的omniauth已经支持大多数网络第三方验证系统，这样以来，Rails3版本的RefactorMyCode将允许你使用很多的第三方验证系统登录，比方借助[github](http://github.com), [twitter](http://twitter.com)和[linkedin](http://linkedin.com)等网站的用户名和密码，你都可以顺利访问RefactorMyCode。

做好准备好开源了吗?
-------------------

回答是：YES!

该项目的代码已经在github开源，请点击[这里](https://github.com/intridea/refactormycode)查看。需要补充一点，目前针对Rails3版本的rSpec测试代码还差很多，希望更多的人能参与进来，和我一起将RefactorMyCode变成更有人气的技术类社区。
