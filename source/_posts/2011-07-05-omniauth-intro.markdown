---
title: OmniAuth, 昨天今天明天
author: Terry Tai
layout: post
date: 2011-07-05 17:35
comments: true
sharing: true
categories:
  - Ruby
  - Authentication
  - TeaHour
  - Rack
---

[OmniAuth]: https://github.com/intridea/omniauth
[RailsRumble]: http://railsrumble.com/
[Railscasts]: http://railscasts.com/
[Michael Bleigh]: http://intridea.com/about/people/mbleigh
[OAuth]: http://oauth.net/
[twitter]: http://twitter.com
[Devise]: https://github.com/plataformatec/devise


[OmniAuth][]作为一个优秀Ruby第三方服务认证库，自从去年[RailsRumble][]以来就一路走红。一方面是随着第三方服务认证的流行，另一方面也多亏[Railscasts][]的大力宣传。本文就简单介绍一下OmniAuth的现状以和来的发展方向,以及如何让他成为你的唯一认证平台。

OmniAuth是一个开源项目，是咱Intridea大牛[Michael Bleigh][]之作。对OmniAuth实现有兴趣的朋友，或者希望贡献provider的同学，不妨clone下来看看.

首先我们简单的介绍一下OmniAuth如何使用。OmniAuth是Rack-based的，所以你可以在任何你的Rack application里使用它。

<!-- more -->

这里我们就以Rails3作为例子。

首先安装Omniauth gem:

```ruby Gemfile
gem "omniauth"
```

```
bundle install
```

初始化设置


```ruby config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
```

这里我们初始化一个叫twitter的provider, 一种provider对应着一种认证策略，这里我们初始化的是twitter认证方式. 而目前omniauth已经支持了几十种provider，而且还在不断的增加。甚至连祖国的人人，淘宝，QQ, 163等都已经支持。如果这还不能满足你，也没关系, 后面我们也会对如何自己实现provider做进一步介绍。

这里初始化provider后，omniauth为我们提供了两个重要的url

- `/auth/:provider`

- `/auth/:provider/callback`

我们把前者称为request phase， 后者为callback phase。
顾名思义，当我们访问前者，如 `/auth/twitter`, 那么omniauth视为你要做[twitter][] 的[OAuth][]的认证, 并把你redirect到twitter做认证。当认证成功后，会redirect到的callback url,也就是 `/auth/twitter/callback`。
通常我们会在route当中把此url指定到我们`sessions#create`, 当然，这还得根据你的需求。

```ruby config/routes.rb
match "/auth/:provider/callback" => "sessions#create"
```

接下来我们看看`sessions#create`

```ruby app/controllers/sessions_controller.rb
def create
  auth = request.env["omniauth.auth"]
  user = User.from_auth(auth)
  session[:user_id] = user.id
  redirect_to root_url, :notice => "Welcome #{user.name}"
end
```

以及`User` model

```ruby app/models/user.rb
def.self.from_auth(auth)
  find_by_provider_and_uid(auth["provider"], auth["uid"]) || 
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["user_info"]["name"]
    end
end
```

在create action中，我们从`request.env["omniauth.auth"]`中就能轻松的拿到一切我们需要的用户信息。而拿到以后如何处理，就不再是omniauth需要负责的问题了。
这一切都显得如此简洁和直观。

在OmniAuth诞生的初期，它只负责于做第三方应用的的认证，而如果我们的应用需求还包含传统的帐号密码方式的认证，我们则需要和其他的认证库结合使用，比如[Devise][]等。

而值得高兴的是，在未来的1.0版本中，Omniauth将支持传统的帐号密码的方式来进行认证，这也就让Omniauth具备成为唯一的认证方案的可能。如果想提前尝试一下的朋友，我们可以checkout 1.0-beta这个分支。

以下我们来看看如何使用传统的基于帐号密码的方式来进行认证。

在1.0中，我们会有一种特殊的provider叫identity, 和其他provider一样，我们只需在initializers里初始化它。

```ruby config/initializers/omniauth.rb
provider :identity, :fields => [:name, :email, :nickname]
```

如果用identity这种认证方式，我们还需要在model中建立一个Identity类

```ruby app/models/identity.rb
class Identify < OmniAuth::Identify::Models::ActiveRecord
  validates_presence_of :email, :name, :nickname
  validates_uniqueness_of :email
end
```

略有不同的是，这个类继承于`OmniAuth::Identify::Models::ActiveRecord`, 而不是`ActiveRecord::Base`。
但你完全可以像使用一个普通的ActiveRecord model一样来使用它。

除此之外，我们还需要添加一个注册表单。
唯一需要注意的是这个表单需要post 到`/auth/identity/register`这个url。
这个url只在 identity 这种认证策略中存在，用于注册新用户。
而登陆仍然对应 `/auth/identity` 
登陆成功后会redirect 到 `/auth/identity/callback`中。同样通过`request.env["omniauth.auth"]`拿到所有的用户信息，这样就和其他的provider非常好的统一了起来。

我相信绝大部分的用户可能把Omniauth完全当作一个黑盒来使用，我们给出一个请求，然后拿到用户信息。
但是实际上如果你想自己动动手脚，写写自己的provider也是十分容易的。

首先要明白的一点，前面也提到了：

1. 每一个provider就是一种认证策略
2. 每一个策略都有两个phases (rquest phase, callback phase)

这里我们就以一个developer provider为例。自己动手实现一个provider.

当然，这个provider的需求也十分简单。

需求：由于种种原因，或许我们不能链接互联网或许我们的互联网被*了，所以此时此刻我们的应用需要做twitter认证就是一件很麻烦的事情。而我们现在就要建立一个developer provider来让我们在开发过程中使用，避免访问到twitter去认证，并且能拿到相同格式的twitter用户信息, 以完成认证。

我们可以在我们lib目录下创建一个developer_strategy.rb.并做如下实现。

```ruby developer_strategy.rb
require 'omniauth/core'
module OmniAuth
  module Straegies
    class Developer
      include OmniAuth::Strategy
      
      def initialize(app, *args)
        supper(app, :developer, *args)
      end
      
      def request_phase
        OmniAuth::Form.build url:callback_url, title: "Hello developer" do
          text_field "Name", "name"
          text_field "Email", "email"
          text_field "Nickname", "nickname"
        end.to_response
      end
      
      def auth_hash
        {
          'provider' => 'twitter'
          'uid' => request['email'],
          'user_info' => 
          {
            'name' => request['name'],
            'email' => request['email'],
            'nickname' => request['nickname']
          }
        }
      end
    end
  end
end
```

通常情况下我们都只需要重写 request_phase，callback_phase，auth_hash方法。
这里request_phase很好解释，我们直接给用户一个表单，让用户自行填写，并把填写的内容作为认证后的用户信息传给callback phase. 而auth_hash就对应了我们的用户信息的hash。这里我们没有重写callback_phase是因为默认的callback_phase行为已经完全符合我们的需求。

而如果要使用这个provider也十分简单，我们只需要在同样的地方对它进行初始化即可

```ruby
require 'developer_straegy'
provider :developer
```

是不是很简单？  
好了，关于omniauth我们就谈到这里吧。  
Hope you will like it. Enjoy. :)
