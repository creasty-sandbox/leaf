
class Leaf.Accessible

  constructor: ->
    @_accessors = {}

  @_isAccessible: true
  __isAccessible: true

  accessors: (accessors, obj = @) ->
    return unless accessors
    @_accessor attr, obj for attr in accessors

  removeAccessors: (accessors, obj = @) ->
    return unless accessors
    @_removeAccessor attr, obj for attr in accessors

  _accessor: (attr, obj = @) ->
    @_accessors[attr] = 1

    Object.defineProperty @, attr,
      enumerable: true
      configurable: true
      get: => obj._get attr
      set: (val) => obj._set attr, val

  _removeAccessor: (attr, obj = @) ->
    @_accessors[attr] = undefined

    Object.defineProperty obj, attr,
      enumerable: false
      configurable: true
      value: undefined


