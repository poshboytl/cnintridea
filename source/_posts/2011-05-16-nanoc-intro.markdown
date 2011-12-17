---
title: 使用Nanoc生成静态网站
author: Ian Yang
layout: post
date: 2011-05-16 17:35
comments: true
gallery: 2011-05-16-nanoc-intro
categories:
  - Ruby
  - Nanoc
  - TeaHour
---

[Nanoc][]是用Ruby实现的一个静态网站生成系统。Nanoc被设计为一个通用的编译框架，Gems以及命令行工具都能很方便的集成在Nanoc中。

Nanoc的编译过程使用Ruby DSL来进行配置。还可以在任何地方使用ERB来访问各种数据，根据这些数据来动态生成某些内容。任一个输入文件都能够访问自己或其它任意一个输入文件在编译各个阶段所产生的结果，并且Nanoc会通过这些引用检测依赖关系，并自动调整编译顺序。

~~<http://cn.intridea.com>整个网站正是由Nanoc生成的。~~
<ins>最新的网站已迁移到[Octopress](http://octopress.org)。</ins>

<!--more-->

静态生成的优点
--------------

使用Nanoc静态生成网站，大部分内容就可以使用纯文本。所以可以用版本控制系统比如git来管理来跟踪历史和管理更改，使用各种脚本、命令来生成和加工内容，使用你喜爱的编辑器进行写作等等。同时生成的网站容易部署，只需要一台能够上传文件的HTTP服务器(支持HTTP的虚拟主机、[GitHub Pages][]、[Amazon S3](http://aws.typepad.com/aws/2011/02/host-your-static-website-on-amazon-s3.html))。当要迁移网站时，也仅需要重上传到新的服务器上(当然如果修改域名需要修改些配置并重新生成整个网站)。

安装和使用
----------

Nanoc可以通过`gem`安装，根据系统环境，您可能需要使用`sudo gem`。

```console
$ gem install nanoc3
```

其它的gems可以根据需要安装。有些用于各种标记语言的编译，有些用于直接修改HTML，有
些用于添加额外功能，比如代码高亮，有些用于预览生成的网站。

```console
$ gem install kramdown
$ gem install nokogiri
$ gem install coderay
$ gem install adsf
```

通过`nanoc3`就可以产生网站模板并编译了。

```console
$ nanoc3 create_site sample
$ cd sample
$ nanoc3 compile
$ nanoc3 view
```

打开<http://localhost:3000>就可以看到Nanoc生成的网站了。


生成过程
--------

Nanoc生成网站分为三个步骤，加载、编译和Route(见下图)。加载通过`config.yaml`配置，编
译和Route在`Rules`文件中配置。

{% gimg /compile.png Nanoc生成步骤 %}

### 加载 ###


加载阶段中，Nanoc从*Data Source*(数据源)中读取所有*items*(输入文件)和*layouts*(模
板)。Data Source通过`config.yaml`中的`data_sources`项进行配置。默认配置为

```yaml
data_sources:
  -
    type: filesystem_unified
    items_root: /
    layouts_root: /
```

默认的`filesystem_unified`会从`content`目录下加载输入文件，从`layouts`下加载模板。
Data Source负责为每个输入文件生成一个*identifier(标识符)*。`filesystem_unified`生
成的标识符是`content`下的相对路径去掉后缀名后前后添加斜杠：

```
content/foo/bar.baz.html    → /foo/bar/
content/foo/bar/index.html  → /foo/bar/
content/foo.bar/index.html  → /foo.bar/
```

如果有文件只有后缀名不同，就会造成名字冲突。可以通过更改文件名、移动到不同目录、或者是使用自定义数据库来解决。自定义数据源只需要继承[Nanoc3::DataSource][]并实现`items`和/或`layouts`。例如[FilesystemAssetsDataSource](https://github.com/doitian/iany.me/blob/master/lib/filesystem_assets_data_source.rb)从`asserts`目录下加载输入文件并使用包含后缀名的相对路径来作为标识符。

通过`filesystem_utnified`加载的输入文件可以在文件开头处包含YAML格式的Hash，必须用三个横杠开始和结束从而和正文分开。这个Hash将作为输入文件的元数据加载，并能通过`Item#[]`方法访问，例如`item[:title]`

```
---
title: Hello, World
author: ian
---

<p>
  This is a sample post
</p>
```

### 编译 ###

每个输入文件可以编译产生一个到多个*Rep(Representation)*。这是通过`Rules`文件进行配置的。

```ruby
# 缺省:rep为:default
compile '/bar/*' do
  filter :erb
  filter :kramdown
  layout 'default'
end

compile '/bar/*', :rep => :raw do
  # 留空将不作任何处理
end
```

`compile`的第一个参数为包含通配符"*"的字符串，或者正则表达式。它用于匹配输入文件
的标识符。每个Rep会在Rules文件在从上到下找到每个匹配的`compile`块作为它的编译规则。
一条编译规则由`filter`, `layout`和`snaptshot`等步骤任意排列得到。每个步骤从上一步
从得到输入，处理后将结果作为下一步的输入，从而形成一条管道。

`Filter`是实现了
[run](http://nanoc.stoneship.org/docs/api/3.1/Nanoc3/Filter.html#run-instance_method)
方法的类。比如，`:erb`执行并替换输入中的Ruby代码片段，`:kramdown`把输入中
markdown标记转化为HTML。

`Layout`则是使用`layouts`下的模板文件。

`Snapshot`保存当前编译结果的快照。所有的快照都能够通过[Item#compiled_content][]访问。

compile块、item和layout的ERB都使用的[Nanoc3::RuleContext][]。

你可以访问以下变量

- `rep`: 当前正在编译输入文件的rep
- `item`: 当前正在编译的输入文件
- `site`: 当前生成网站的信息
- `config`: 由`config.yaml`生成的Hash
- `items`: 所有加载的输入文件
- `layouts`: 所有加载的模板

在compile块中可以使用这些变量选择编译规则，比如

```ruby
compile '/*' do
  case item[:extension]
  when 'md'
    filter :kramdown
  when 'haml'
    filter :haml
  when 'sass'
    filter :sass
  end
  layout item[:layout] if item[:layout]
end
```

在item和layout的ERB中可以使用这些变量来动态生成某些内容。比如下面的模板`layouts/default.html`:

```rhtml
<html>
<head><title><%%= item[:title] || File.basename(item.identifier) %></title></head>
<body><%%= yield %></body>
</html>
```

### Route ###

Route规则用于指定Rep在输出目录中的保存路径。由于静态网站的路径即为URL，所以也可以认为是指定Rep的URL。

```ruby
# 缺省:rep为:default
route '/images/' do
  identifier.chop + '.' + item[:extension]
end

# 缩略图保存在 output/images/thumbnails
route '/images/', :rep => :thumbnail do
  filename = identifier.sub(%r{^/images/}, '\&thumbnails/'})
  filename.chop + '.' + item[:extension]
end

route '/posts/', :rep => :summary do
  # 留空则编译结果不写到输出文件中
  # 编译结果仍然可能通过compiled_content访问
end
```

Nanoc网站示例
-------------

- [Compass][]的网站由Nanoc生成，源文件可以在[GitHub](https://github.com/chriseppstein/compass/tree/stable/doc-src)上查看。
- [Nanoc-slidy](http://doitian.github.com/nanoc-slidy/)布署在GitHub Pages上，用Nanoc和[Slidy][]生成幻灯片。
- 我用Nanoc搭建的个人博客和Wiki: <http://iany.me>，源代码在[Github](http://github.com/doitian/iany.me)。

这篇文章最初为Intridea East团队每周五Tea Hour上分享的主题。你可以在Nanoc-slidy上找到[幻灯片](http://doitian.github.com/nanoc-slidy/nanoc-intro/)。

[Nanoc]: http://nanoc.stoneship.org/ "Nanoc, a Ruby web publishing system"
[GitHub Pages]: http://pages.github.com/
[Nanoc3::DataSource]: http://nanoc.stoneship.org/docs/api/3.1/Nanoc3/DataSource.html
[Item#compiled_content]: http://nanoc.stoneship.org/docs/api/3.1/Nanoc3/Item.html#compiled_content-instance_method
[Compass]: http://compass-style.org "Open source CSS Authoring Framework"
[Slidy]: www.w3.org/Talks/Tools/Slidy2/
[Nanoc3::RuleContext]: http://nanoc.stoneship.org/docs/api/3.1/Nanoc3/RuleContext.html
