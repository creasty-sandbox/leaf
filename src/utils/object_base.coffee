
class ObjectBase

  _uuid = 0

  constructor: -> @_objectBaseInit()

  _objectBaseInit: ->
    @_c = @constructor
    @_uuid = ++_uuid
    @_cacheManager = new CacheManager()
    @_cacheManager.set @toUUID(), @

  toUUID: -> "UUID#{@_uuid}"

