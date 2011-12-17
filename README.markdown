快速发博
--------

博客基于Octopress, 先了解[Octopress](http://octopress.org/docs)

请使用[markdown](http://daringfireball.net/projects/markdown/syntax)编写(蛋疼也
可以用html, haml)

### 文章模板 ###

** Octopress 使用Rake task来生成，在cnintridea中使用用thor **

#### 生成博文 ####

    thor post:new slug [--title STRING] [--author STRING]

比如:

    thor post:new hello-world --title 你好 --author "Ian Yang"


#### 生成页面 #####

    thor page:new slug

比如:

    thor page:new about

#### 预览 ####

你可以自动编译并启动webrick预览:

    rake preview

或者只自动编译:

    rake watch

然后使用pow, nginx等来预览public下生成网站。

如果页面不刷新，尝试退出preview或watch，然后手动重新生成:

    rm -rf public
    rake generate

如果文章较多，可以把其它文章stash

    thor post:isolate [keyword]

比如

    thor post:isolate hello

keyword用来匹配文件名，除了你选择的文章，其它都会移到其它文件夹。

记得提交到把他们话回来:

    thor post:integrate

### 元信息 ###

文件开头以`---`开始和结尾的为YAML格式的元信息

-   `title`: 如果生成的时候没指定，会根据文件名生成，根据需要更改
-   `author`: 如果生成的时候没指定，需要手动填入名字
-   `categories`: 会作为tags来使用
-   `comment: false` 禁用评论
-   `sharing: false` 不显示文章底部的分享按钮
-   `gallery`: 为`{% gimg %}`指定前缀，参考下面*图片和附件*.

风格指南
--------

### 文章结构 ###

-   以markdown二级标题(`____`或者`## title ###`)开始，一级标题预留给layouts使用。
-   文章很长，可以在第一个二级标题前加些段落简要介绍文章的内容，并用`<!-- more
    -->`和下面的详细内容分隔开。
-   建议在开头处配上一张小图。

### 图片和附件 ###

-   使用 `{% img %}` 来插入图片 [ImageTag](http://octopress.org/docs/plugins/image-tag/)
-   图片和附件放入gallery文件夹
-   一篇文章需要使用很多图片的话，在gallery下建立个子目录，再文章的YAML中用
    gallery属性指定这个目录，然后使用`{% gimg %}`来插入图片。参数和`img`相同，只
    是不用重复输入前缀。参考
    `source/posts/2011-07-11-the-docks-of-intridea-east.markdown`.
-   大文件(比如 >1M)，放到外部服务(文件分享服务，图床)，不要放到git repo里

### 代码 ###

-   使用fenced code block来插入代码
-   分享文件可以用gist或者include本地文件(加到git中)
-   详细参考 [Sharing Code](http://octopress.org/docs/blogging/code/)

### 活用插件 ###

[Octopress Plugins](http://octopress.org/docs/blogging/plugins/)

License
-------

(The MIT License)

Copyright © 2009-2011 Brandon Mathis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#### If you want to be awesome.
- Proudly display the 'Powered by Octopress' credit in the footer.
- Add your site to the Wiki so we can watch the community grow.
