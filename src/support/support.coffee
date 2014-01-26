
class Leaf.Support

  @add: (klass) ->
    extendee = klass.__super__ ? Object
    instance = new klass()

    addClassMethod extendee, method, fn for own method, fn of klass
    addInstanceMethod extendee, method, fn for own method, fn of instance

  addClassMethod = (extendee, method, fn) ->
    extendee[method] = -> fn @, arguments...

  addInstanceMethod = (extendee, method, fn) ->
    extendee::[method] = -> fn @, arguments...

###
SubNumber = ->
  n = new Number arguments...
  n.__proto__ = SubNumber::
  n

SubNumber:: = new Number()
SubNumber::succ = -> new @constructor @ + 1
###

