
PlainObject = Object

class Leaf.Object extends PlainObject

  @_objectType = 'Object'

  _leafID = 0

  constructor: -> @_objectBaseInit()

  _objectBaseInit: ->
    @_leafObject = true
    @_leafID = ++_leafID
    @_c = @constructor
    @_cache = new Leaf.Cache()
    @_cache.set @toLeafID(), @
    @_accessors = {}

  accessors: (accessors, obj = @) ->
    return unless accessors
    @_accessor attr, obj for attr in accessors

  removeAccessors: (accessors, obj = @) ->
    return unless accessors
    @_removeAccessor attr, obj for attr in accessors

  _accessor: (attr, obj = @) ->
    @_accessors[attr] = 1

    PlainObject.defineProperty @, attr,
      enumerable: true
      configurable: true
      get: => obj.get attr
      set: (val) => obj.set attr, val

  _removeAccessor: (attr, obj = @) ->
    @_accessors[attr] = undefined

    PlainObject.defineProperty obj, attr,
      enumerable: false
      configurable: true
      value: undefined

  toString: -> "<#{@getLeafClass()}.#{@_c.name} #{@_leafID}>"
  toLeafID: -> "__LEAF_ID_#{@_leafID}"

  getLeafClass: -> "Leaf.#{@_c._objectType}"

  @isLeafID: (id) ->
    return false unless _.isString id
    !!id.match /^__LEAF_ID_\d+$/

