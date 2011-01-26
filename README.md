# CoffeeMachine

These are some scripts I hacked together to work with CoffeeScript.

This is a first draft. Your mileage may vary.

## Installing

* You'll need Ruby 1.9.2. Using [RVM](http://rvm.beginrescueend.com) is advised.

* You can make a submodule to this in your own project:

      git submodule add git@github.com:iain/coffee-machine.git vendor/coffee-machine
      git submodule update --init

* Create a file called `Thorfile` and add:

      load File.expand_path('../vendor/coffee-machine/thor.rb', __FILE__)

* Create a file called `Gemfile` and add the contents of the Gemfile in this repository.
* Install the dependencies:

      gem install bundler
      bundle install

## Compiling

Compiling is done according to naming conventions. This is not yet configurable.

Loose scripts are expected to be in `src/myscript.coffee` and are compiled to `public/myscript.js`.

Any coffee files in subdirectories and are concatinated.
So `src/mymodule/*.coffee` are compiled into `public/mymodule.js`

To compile everything run:

    thor coffee:compile

You can compile loose files too:

    thor coffee:compile src/myfile.coffee

Start a watcher, to compile whenever you save a file:

    thor coffee:watch

## AutoRefresh

Using the AutoRefresh gem, everytime you change a file in the `public` directory, the browser will
reload. You need to add some scripts to your page, so be sure to checkout
the [documentation](https://github.com/logankoester/autorefresh).


------------

(c) Iain Hecker, 2011. Released under the MIT-License. Look it up yourself.
