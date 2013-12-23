
Leaf
====

Client-side MVC framework for rails projects




Features
========

- MVC architecture
- Hight affinity to Ruby on Rails projects
- Beautiful view template markups
- Powerful two-way data binding system
- View components
- CoffeeScript in mind




Sample
======

```coffee
class window.App extends Leaf.App
```


Model
-----

```coffee
class App.Author extends Leaf.Model
  
  @accessors 'firstname', 'lastname'

  @hasMany 'posts'

  fullname: -> "#{@firstname} #{@lastname}"


class App.Post extends Leaf.Model

  @accessors 'title', 'content'

  @hasMany 'comments'
  @belongsTo 'author'


class App.Comment extends Leaf.Model

  @accessors 'email', 'name', 'content'

  @belongsTo 'post'

```


View
----

```html
<!-- posts/index.html -->
<if $condition="posts.length > 0">
  <each $post="posts[]">
    <article>
      <h3>{{ post.title }}</h3>
      <p>{{ post.content.slice(0, 150) }}</p>
    </article>
  </each>
</if>
<else>
  <p>No posts!</p>
</else>
```


Controller
----------

```coffee
class App.PostsController extends Leaf.Controller

  index: ->
    @posts = App.Post.orderBy 'created_at'

```


Routing
-------

```coffee
App.routes ->

  @root 'pages#home'

  @resources 'posts', ->
    @resources 'comments'

```




Building & Testing
==================

You'll need to have Grunt and Bower installed.

```shell
$ npm install
$ bower install
```

Available grunt commands are:

```shell
# Development: do less, compile coffee
$ grunt dev

# Test: compile coffee and run test with Jasmine on PhantomJS
$ grunt test
$ grunt test --filter group_name

# Release: concatenate all files and create a minified version
$ grunt release
```




Contributing
============

Bug reports
-----------

1. Ensure the bug can be reproduced on the latest master.
1. Check it's not a duplicate.
1. Raise an issue.


Pull-requests
-------------

Contributions are always welcome!

1. Fork the repository.
1. Create a feature branch. (this project is using git-flow)
1. Write tests first.
1. Write test-driven code.
1. Update the documentation if need.
1. Create a pull request.




License
=======

This project is copyright by [Creasty](http://www.creasty.com), released under the MIT lisence.  
See `LICENSE` file for details.

