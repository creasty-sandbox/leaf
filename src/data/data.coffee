
class Leaf.Data

  inject = (primitive, implement) ->
    klass = (o) ->
      o = new primitive o
      implement.call o
      o.__proto__ = klass::
      o

    klass:: = new primitive()
    klass::[name] = method for name, method of implement::
    klass::__primitiveClass = primitive

    klass

  @add: (klass) ->
    primitive = switch klass.name.replace(/^Leaf/, '')
      when 'Date'   then Date
      when 'Number' then Number
      when 'String' then String
      else throw new TypeError()

    k = inject primitive, klass
    primitive::ldata = -> new k @
    Leaf[primitive.name] = k

  __leafData: true

  setParent: (obj, prop) ->
    return unless obj

    @_hasParent = true
    @_parentObj = obj
    @_parentProp = prop

  unsetParent: ->
    @_hasParent = false
    @_parentObj = null
    @_parentProp = null

  get: ->
    if @_hasParent
      @_parentObj._get @_parentProp
    else
      @

  set: (val) ->
    unless @_hasParent
      throw new SetterOnOrphanObjectError val

    val = new @__primitiveClass(val).ldata()
    @_parentObj._set @_parentProp, val


Object::ldata = -> new Leaf.ObservableObject @
Array::ldata = -> new Leaf.ObservableArray @


