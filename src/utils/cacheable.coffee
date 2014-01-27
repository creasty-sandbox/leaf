
class Leaf.Cacheable extends Leaf.Identifiable

  __cacheable: true

  @cacheGroup = null # default

  constructor: ->
    super()
    @_cache = new Leaf.Cache @constructor.cacheGroup
    @_cache.set @toLeafID(), @ if @constructor.cacheable == true

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

