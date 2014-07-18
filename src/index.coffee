Observable = require './observable'


o = Observable.make
  a: Observable.make
    d: Observable.make
      e: 'eclipse'
  b: ->
    @a.d.e
    @x
    @
  x: -> @c
  c: 'charie'


t = o.getEventTracker 'get'

o.b.a.d
o.a.b
o.a.d.e
o.c

console.log t.getActiveKeypaths()
