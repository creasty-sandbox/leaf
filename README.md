
Leaf
====

Client-side MVC framework for rails projects


Features
--------

- MVC architecture
- Hight affinity to Ruby on Rails projects
- Beautiful view template markups
- Powerful two-way data binding system
- View components
- CoffeeScript in mind


Building & Testing
------------------

You'll need to have Grunt and Bower installed.

```sh
$ npm install
$ bower install
```

Available grunt commands are:

```sh
# Development: do less, compile coffee
$ grunt dev

# Test: compile coffee and run test with Jasmine on PhantomJS
$ grunt test
$ grunt test --group test_group --filter file_name

# Release: concatenate all files into one and create its minified version
$ grunt release
```


Contributing
------------

Contributions are always welcome!

### Bug reports

1. Ensure the bug can be reproduced on the latest master.
2. Check it's not a duplicate.
3. Raise an issue.


### Pull-requests

1. Fork the repository.
2. Create a branch.
3. Run tests.
4. Write test-driven code.
5. Update the documentation if necessary.
6. Create a pull request.


License
-------

This project is copyright by [Creasty](http://www.creasty.com), released under the MIT lisence.  
See `LICENSE` file for details.

