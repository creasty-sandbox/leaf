
class Leaf.Object

  _uuid = 0

  constructor: -> @_objectBaseInit()

  _objectBaseInit: ->
    @_c = @constructor
    @_uuid = ++_uuid
    @_cache = new Leaf.Cache()
    @_cache.set @toUUID(), @

  accessors: (accessors, obj = @) ->
    return unless accessors
    @_accessor attr, obj for attr in accessors

  removeAccessors: (accessors, obj = @) ->
    return unless accessors
    @_removeAccessor attr, obj for attr in accessors

  _accessor: (attr, obj = @) ->
    window.Object.defineProperty @, attr,
      enumerable: true
      configurable: true
      get: => obj.get attr
      set: (val) => obj.set attr, val

  _removeAccessor: (attr, obj = @) ->
    window.Object.defineProperty obj, attr,
      enumerable: false
      configurable: true
      value: undefined

  toUUID: -> "UUID#{@_uuid}"

