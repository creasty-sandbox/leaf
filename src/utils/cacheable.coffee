
class Leaf.Cacheable extends Leaf.Identifiable

  __cacheable: true

  @cacheGroup = null # default

  constructor: ->
    @_cache = new Leaf.Cache @constructor.cacheGroup
    @_cache.set @toLeafID(), @ if @constructor.cacheable == true

