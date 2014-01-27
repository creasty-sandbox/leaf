
class Leaf.Cacheable extends Leaf.Identifiable

  __cacheable: true

  @cacheGroup = null # default

  constructor: ->
    super()
    @_cache = new Leaf.Cache @constructor.cacheGroup
    @_cache.set @toLeafID(), @ if @constructor.cacheable == true

  getCache: (key) -> @_cache.get key
  setCache: (key, val) -> @_cache.set key, val
  clearCache: (key) -> @_cache.clear key

  @findOrCreate: (id, factory = null) ->
    cache = new Leaf.Cache @cacheGroup

    if (obj = cache.get id)
      obj
    else
      obj =
        if _.isFunction factory
          factory @
        else
          new @()

      cache.set id, obj
      obj

