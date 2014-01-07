
class Leaf.Cacheable extends Leaf.Identifiable

  constructor: ->
    @_cache = new Leaf.Cache @constructor.cacheGroup
    @_cache.set @toLeafID(), @ if @constructor.cacheable == true

  @_isCacheable: true
  __isCacheable: true

  @cacheGroup = null # default

