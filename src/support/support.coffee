
class Leaf.Support

  @add: (klass) ->
    extendee = klass.__super__ ? Object
    instance = new klass()
    obj = (@[extendee.name] ?= {})

    addMethod obj, extendee, method, fn for own method, fn of instance

  addMethod = (obj, extendee, method, fn) ->
    obj[method] = fn
    extendee::[method] = -> fn @, arguments...

  @resetPrototypeMethods: ->
    for ctor in supportClasses
      methods = klass[ctor.name]

      for method of methods when method != 'add'
        ctor::[method] = undefined

    null

