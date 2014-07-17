
class Leaf.Cacheable extends Leaf.Identifiable

  __cacheable: true

  @cacheGroup = null # default

  constructor: ->
    super()
    @_cache = new Leaf.Cache @constructor.cacheGroup
    @_cache.set @toLeafID(), @

  getCache: (key) -> @_cache.get key

  setCache: (key, val, override) -> @_cache.set key, val, override
  unsetCache: (key) -> @_cache.unset key

  clearCache: (key) -> @_cache.clear key

