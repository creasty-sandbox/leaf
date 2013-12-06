
class Leaf.Object

  _uuid = 0

  constructor: -> @_objectBaseInit()

  _objectBaseInit: ->
    @_c = @constructor
    @_uuid = ++_uuid
    @_cache = new Leaf.Cache()
    @_cache.set @toUUID(), @

  toUUID: -> "UUID#{@_uuid}"

