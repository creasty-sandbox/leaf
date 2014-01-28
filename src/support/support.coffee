
class Leaf.Support

  @add: (klass) ->
    primitive = switch klass.name.replace(/Support$/, '')
      when 'String' then String
      when 'Number' then Number
      when 'Object' then Object
      when 'Date'   then Date

    instance = new klass()

    for method, fn of klass
      addMethod primitive, method, fn.bind(klass)

    for method, fn of instance when method != 'constructor'
      addMethod primitive::, method, fn.bind(instance)

    null

  addMethod = (to, method, fn) -> to[method] = -> fn @, arguments...

  @inject: (to, implement) ->
    klass = ->
      o = new to arguments...
      o.__proto__ = implement::
      o

    klass:: = new to
    _.extends klass, implement
    _.extends klass::, implement::

    klass

