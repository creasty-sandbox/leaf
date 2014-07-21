class Cache

  storage = _global: {}

  constructor: (@namespace = '_global') ->
    @storage = (storage[@namespace] ?= {})

  get: (key, set) -> (@storage[key] ?= set)

  set: (key, val, override = false) ->
    if !override && @storage[key]?
      @storage[key]
    else
      @storage[key] = val

  unset: (key) -> @set key, undefined, true

  clear: (key) ->
    @storage = (storage[@namespace] = {})

  findOrCreate: (key, factory) ->
    obj = @get key

    return obj if obj

    obj = factory()

    @set key, obj

    obj


module.exports = Cache
