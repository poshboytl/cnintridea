---
title: 全文索引与Solr集成 
author: Dexter Deng
layout: post
date: 2011-05-24 17:35
categories:
  - Rails
  - Solr
  - Sphinx
  - TeaHour
comment: true
---

[Sphinx]是目前ROR世界里是使用最普遍的全文检索引擎，我们通常可以使用
[thinking_sphinx]来集成，可以很方便的吧Sphinx全文索引的优势带到项目中。

然而，相对而言，作为另外一个全文检索的强者－[Solr]却较少为人所关注。 其实与
[Sphinx]相比，[Solr]能给我们带来更多的实惠。 
   
比如, Solr可以给我们带来：
    
-   `Solr` 可以精确控制对索引进行局部更新，而Sphinx只能全局更新
-   `Solr` 可以对几乎任何对象进行索引，该对象甚至可以不是ActiveRecord.而Sphinx和RDBMS耦合过于紧密
-   `Solr` 索引的对象ID可以非空或者是字符串，而Sphinx要求被索引对象必须拥有非0整数作为ID
-   `Solr` 支持Boolean作为查询条件搜索,更加方便
-   `Solr` 支持Facets,而Sphinx为此需要做更多工作
-   `Solr` 是对lucene的包装。所以他可以享受lucene每次升级带来的便利。

综上，我们完全有理由对Rails项目里也能够使用Solr的这些便利而感到兴奋不已了。

<!--more-->

安装:
-----

言归正传,接下来介绍Solr集成部。

Solr集成主要使用到以下几插件:

-    Sunspot
-    Sunspot_rails
-    Rsolr
-    Java 1.5+

### 基于Rails 3安装 ###

将一下内容添加到Gemfile里   

    gem 'sunspot_rails', '~> 1.2.1'

使用bundle安装 

    bundle install

产生config/sunspot.yml配置文件

    rails g sunspot_rails:install
       
### 基于Rails 2.*安装 ###

#### 将以下内容添加到config/environment.rb ####

```ruby config/environment.rb
config.gem 'sunspot', :version => '1.1.0'
config.gem 'sunspot_rails', :lib => 'sunspot/rails', :version => '1.1.0'
```

截至发稿时为止，经过测试能行的通道的依然是1.1.\*版本，所以Rails2.\*系列的兄弟建议采用1.1.0。1.2.1是把sunspot,sunspot_rails两个插件和在一起，不过似乎没有在rails2.*上进行过很好的测试。顺便提一句，1.2.1的主要提升是在位置搜索方面，重写了位置搜索的引擎。

#### 安装插件: ####

    rake gems:install

当然你也可以分别用gem install安装,或者script/plugin install ..安装.

#### 产生config/sunspot.yml: ####

    script/generate sunspot

#### 把一下内容添加到Rakefile中: ####

    require 'sunspot/rails/tasks'

     
### Solr服务控制 ###

将以上内容添加到Rakefile后，将会多出4个task出来

#### 服务器启动: ####

    rake sunspot:solr:start

初次启动，会安装一个embed的solr程序，那么开发环境中省去了安装配置Solr环境繁琐步骤。不过，production环境里可不要使用这个embed版。

#### 服务器停止: ####

    rake sunspot:solr:stop

#### 全部重建索引：####

    rake sunspot:reindex

#### 如果你想看到运行日志，把服务跑在前端。可以使用一下命令: ####

    rake sunspot:solr:run
    
使用以上命令，就能完成对Sunspot的控制。

Model 集成
----------

### 自动方式定义: ###

这种方式和Sphinx一样简单,而且，相对而言，Solr的DSL功能显得更加丰富。

```ruby post.rb
class Post << ActiveRecord::Base 
  has_many :links

  searchable :auto_index => true, :auto_remove => true do
    text :ab  #可以被fulltext或者keywords搜索出来。btw,keywords是fulltext的别名。其实是同一个方法。
    string :location
    integer :blog_id
    boolean :generated   #支持boolean查询
    time :published_at, :stored => true
    text :links do   # 支持这种虚拟属性。
      links.map { |link| link.url + " " + link.title }
    end
  end
end
```

如上，不难看出，sunspot支持text,string, integer, boolean, time, 虚拟属性等等。 而且请留意auto_index,auto_remove,配置了这两个选项以后，程序就能够自动检测程序，数据是否变得脏了。数据脏又分为dirty?和delete_dirty?,自动方式会自动根据这两种脏脏状态决定是否自动更新索引,还是自动删除。如果这两个选项被设置成false,那么就需要你手动更新索引。手动更新的方法将在后面接着叙述。


### 手动方式定义: ###

Sunspot可以对任何对象配置索引功能。即使该对象并不是ActiveRecord。

```ruby post.rb
class Post
  #...
end

Sunspot.setup(Post) do
  text :ab  #可以被fulltext或者keywords搜索出来。btw,keywords是fulltext的别名。其实是同一个方法。
  string :location
  integer :blog_id
  boolean :generated   #支持boolean查询
  time :published_at, :stored => true
  text :links do   # 支持这种虚拟属性。
    links.map { |link| link.url + " " + link.title }
  end
end
```

给class装配好sunspot的的申明之后，我们就可以对数据进行索引，查询，更新,删除等等。
       
查询：
-----

Sunspot的DSL可以拼装复杂的查询条件。而且可以完全支持Will_paginate. 支持排序，还支持named_scope.

```ruby
search = Sunspot.search(Post) do
  keywords 'great pizza'
  with(:published_at).less_than Time.now
  with :blog_id, 1
  without current_post
  facet :category_ids
  order_by :published_at
  paginate 2, 15
end

search.results 
```
   
查询的结果是一个中间对象，要想真正取用查询出来的对象,你需要对查询结果调用`.results`方法。
如上例子可以看到，`keywords`, `less_than`,  `with`, `without`, `facet`这些都是Sunspot的DSL.那么Sunspot还有那些DSL子句可以使用呢？

以下是所有可以使用查询子句：

```ruby
with(:field_name).equal_to(value) 
with(:field_name, value) 
with(:field_name).less_than(value) 
with(:field_name).greater_than(value) 
with(:field_name).between(value1..value2) 
with(:field_name).any_of([value1, value2, value3]) 
with(:field_name).all_of([value1, value2, value3]) 
without(some_instance)
with(:field_name, nil) # ok 
with(:field_name).equal_to(nil) # ok 
order_by :published_at, :desc 
paginate 2, 15
```

使用Sunspot除了可以使用DSL与if..else等组装复杂的查询外，还有一大特点，动态组装查询子句。 

```ruby
search = Sunspot.new_search do
  with(:blog_id, 1)
end
search.build do
  keywords('some keywords')
end
search.build do
  order_by(:published_at, :desc)
end
search.execute
```

与下面等价

```ruby
Sunspot.search do
  with(:blog_id, 1)
  keywords('some keywords')
  order_by(:published_at, :desc)
end
```
 
索引：    
-----

Sunspot可以单独索引一个或者几个对象：

```ruby
post1, post2 = new Array(2) { Post.create }
Sunspot.index(post1, post2) # 可以单独调用Sunspot.commit提交
Sunspot.index(post1, post2) # 立即提交
```

从索引中删除对象:
-----------------

Solr可以从索引里删除单独的对象。

```ruby
remove (*objects, &block) #内存操作，直到commit之后才会写到磁盘。 
remove! (*objects)  #立刻写到磁盘。 
remove_all (*classes)  #删除所有 
remove_all! (*classes) 
remove_by_id (clazz, id) #从索引中删除某个对象。 
remove_by_id! (clazz, id) 
```

下面是几个例子。

```ruby
post.destroy
Sunspot.remove(post) #删除某个对象

Sunspot.remove(Post) do
  with(:created_at).less_than(Time.now - 14.days)
end

Sunspot.remove_all(Post, Blog)
```

Sphinx案例
----------

<http://sphinxsearch.com/info/powered/>

Solr案例
--------

想了解更多Solr的案例: <http://wiki.apache.org/solr/PublicServers>

总结
----

这篇文章首先简要对比了Sphinx与Solr的优劣，让用户逐渐对Solr有所了解。然后具体介绍了Solr集成的细节。希望能对初学者或者没留意Solr的开发人员提供一点帮助。

[Sphinx]: http://sphinxsearch.com/ "Open Source Search Server"
[thinking_sphinx]: http://freelancing-god.github.com/ts/en/ "A Ruby connector between Sphinx and ActiveRecord."
[Solr]: http://lucene.apache.org/solr/ "A fast open source enterprise search platform"
