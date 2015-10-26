---
layout: post
title:  How to create blog
date:   2015-10-24 21:22:04
<!-- categories: jekyll update -->
<!-- tags: ruby rails -->
author: Max Lukin
comments: true
<!-- excerpt: quote -->
---
Before start writing posts for our blog, we at **CustomGears** have tried a lot of other solutions like [Octopress][octopress], [Monologue][monologue], [Blogit][blogit] or [Blogo][blogo]. There's some requirements were for oncoming web site like static pages with information about our agency, contacts page, and blog, which support static files and it's easy to create new ones. And here's an amazing solution we found.

**[Jekyll][jekyll]** is really simple, lightweight tool to create static files and blogs.
It supports markdown, layouts and partials. Here's **[source][customgears]** code of this blog.

Firstly, we have to install gem, let's start:

{% highlight sh %}
$ gem install jekyll
$ jekyll new project
$ cd project
~/project $ jekyll serve

# and this is it! you will see something like:
Configuration file: /Users/project/_config.yml
            Source: /Users/project
       Destination: /Users/project/_site
      Generating...
                    done.
 Auto-regeneration: enabled for '/Users/project'
Configuration file: /Users/project/_config.yml
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
{% endhighlight %}

This means that our blog is running on **http://127.0.0.1:4000/**

We're using **Jenkyll** with [Capistrano][capistrano]. It's extremly simple to setup one.
Iformation how to install [Capistrano][capistrano] you can find in it's repository.
Firslty, let's create Gemfile with content:
{% highlight ruby %}
source 'https://rubygems.org'

# or any other version that you prefer
ruby '2.2.2'

gem 'jekyll'
gem 'capistrano-jekyll',  require: false
gem 'capistrano-bundler', require: false
gem 'capistrano-rvm',     require: false
{% endhighlight %}

Then we're going to install our gems:
{% highlight sh %}
$ bundle install
{% endhighlight %}

Our capify file looks like:

{% highlight ruby %}
# Load DSL and set up stages
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/jekyll'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
{% endhighlight %}


And what about deploy.rb?

{% highlight ruby %}
lock '3.4.0'
server 'IP_OF_YOUR_DIGITALOCEAN_SERVER', user: 'root', roles: %w{app db web}

set :application, 'ApplicationName'
set :repo_url, 'GITHUB_REPO_URL'
set :branch, :master
set :deploy_to, '/home/rails'
set :scm, :git
set :user, :root
set :use_sudo, false

set :format, :pretty
set :keep_releases, 3
set :log_level, :info
set :pty, true

# this setting will allow you to use your local ssh key for auth
set :ssh_options, {
 forward_agent: true
}

{% endhighlight %}

Well, this is it. Now we can create new markdown post, save it into _posts folder, and just run:
{% highlight sh %}
$ bundle exec cap production deploy
{% endhighlight %}

I'm a big fun of DigitalOcean, it's really awesome to deploy any size of project. Works fast, and here's a gift for you, **[10$](https://www.digitalocean.com/?refcode=0f6d5c28d999)** to setup your first instance. Enjoy!

We're [agency](http://customgears.net/#contacts) that helps to bring your ideas into real life. Ping us for help.

[octopress]: http://octopress.org
[monologue]: https://github.com/jipiboily/monologue
[blogit]: https://github.com/KatanaCode/blogit
[blogo]: https://github.com/greyblake/blogo
[jekyll]: https://jekyllrb.com
[customgears]: https://github.com/sesharim/customgears
[capistrano]: https://github.com/capistrano/capistrano
