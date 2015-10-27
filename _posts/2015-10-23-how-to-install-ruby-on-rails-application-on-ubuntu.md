---
layout: post
title:  How to install Ruby on Rails application on Ubuntu
date:   2015-10-20 21:22:04
<!-- categories: jekyll update -->
<!-- tags: ruby rails -->
author: Max Lukin
comments: true
<!-- excerpt: quote -->
---
I'll describe the process of building personal blog on Ruby on Rails from scratch.
But firstly we have to prepare our server for application.

We will use DigitalOcean.
There's a lot of kinds of droplets, Ruby on Rails included, and clean images based on Ubuntu and etc.
I prefer image with Ruby on Rails.

For the first, add your public SSH key for DigitalOcean, just copy it locally like:
{% highlight sh %}
cat ~/.ssh/id_rsa.pub| pbcopy # pbcopy is mac utility that allow you to copy text from console.:
{% endhighlight %}

Then put it to your DO profile.

First ssh connection will ask you for change password:
{% highlight sh %}
$ passwd
{% endhighlight %}

Then we have to add user, which will be responsile for deploying our application:
{% highlight sh %}
$ adduser deployer
{% endhighlight %}

And we'll add him all privileges:
{% highlight config %}
$ visudo
$ deployer ALL=(ALL:ALL) ALL
{% endhighlight %}

This is it for now, le'ts move to another part - software!
Let's start from RVM, ad install it:
{% highlight sh %}
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
$ curl -sSL https://get.rvm.io | bash -s stable
$ source /etc/profile.d/rvm.sh
$ rvm requirements
$ rvm install 2.2.2 --default
{% endhighlight %}

Last postgresql version:
{% highlight sh %}
$ echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
$ wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \ sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install postgresql postgresql-server-dev-9.4 -y
{% endhighlight %}

Let's to allow any connections to our postgresql from localhost:
{% highlight sh %}
$ nano /etc/postgresql/9.4/main/pg_hba.conf
{% endhighlight %}

And replace some configs inside:
{% highlight config %}
local all postgres trust
local all all trust
{% endhighlight %}

Then, restart our postgres server:
{% highlight sh %}
$ sudo service postgresql restart
{% endhighlight %}

Settings password for root user for our DB, and create database for blog:
{% highlight sh %}
sudo -u postgres psql template1
{% endhighlight %}

{% highlight sql %}
ALTER USER postgres with encrypted password 'po$tgr3$$';
create database customgears_production;
{% endhighlight %}

Other sofr - Git, Node.js:
{% highlight sh %}
sudo apt-get install git-core nodejs -y
{% endhighlight %}

In case of our image that included Ruby on Rails, we already have some nginx configs for Rails:
{% highlight sh %}
$ nano /etc/nginx/sites-available/rails
{% endhighlight %}

And nginx config will look like:
{% highlight config %}
upstream app_server {
  server unix:///home/rails/shared/tmp/sockets/puma.sock;
}

server {
        listen   80;
        root /home/rails/current/public;
        server_name customgears.net;
        index index.htm index.html;

        location / {
                try_files $uri/index.html $uri.html $uri @app;
        }

        location ~* ^.+\.(jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|mp3|flv|mpeg|avi)$ {
                        try_files $uri @app;
                }

         location @app {
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_redirect off;
                proxy_pass http://app_server;
    }
}
{% endhighlight %}

We'll just create symlink and make this site config enabled:
{% highlight sh %}
sudo ln -sf /etc/nginx/sites-available/rails /etc/nginx/sites-enabled/rails
sudo service nginx restart
{% endhighlight %}

If you have any questions - just ping us for help.
