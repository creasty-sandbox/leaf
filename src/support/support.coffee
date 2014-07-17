
class Leaf.Support

  @add: (klass) ->
    primitive = switch klass.name.replace(/Support$/, '')
      when 'Array'  then Array
      when 'Date'   then Date
      when 'Number' then Number
      when 'Object' then Object
      when 'String' then String

    instance = new klass()

    for method, fn of klass
      addMethod primitive, method, fn.bind(klass)

    for method, fn of instance when method != 'constructor'
      addMethod primitive::, method, fn.bind(instance)

    null

  addMethod = (to, method, fn) -> to[method] = -> fn @, arguments...

