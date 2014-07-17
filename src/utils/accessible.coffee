
class Leaf.Accessible

  __accessible: true

  constructor: ->
    @_accessors = {}

  accessors: (accessors, obj = @) ->
    return unless accessors
    @_accessor attr, obj for attr in accessors

  removeAccessors: (accessors, obj = @) ->
    return unless accessors
    @_removeAccessor attr, obj for attr in accessors

  defineProperty: (attr, descriptor) ->
    Object.defineProperty @, attr, descriptor

  _accessor: (attr, obj = @) ->
    @_accessors[attr] = 1

    Object.defineProperty @, attr,
      enumerable: true
      configurable: true
      get: -> obj._get attr
      set: (val) -> obj._set attr, val

  _removeAccessor: (attr, obj = @) ->
    @_accessors[attr] = null

    Object.defineProperty obj, attr,
      enumerable: false
      configurable: true

