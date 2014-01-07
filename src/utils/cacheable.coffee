
class Leaf.Cacheable extends Leaf.Identifiable

  @_isCacheable: true
  __isCacheable: true

  @cacheGroup = null # default

  constructor: ->
    @_cache = new Leaf.Cache @constructor.cacheGroup
    @_cache.set @toLeafID(), @ if @constructor.cacheable == true

