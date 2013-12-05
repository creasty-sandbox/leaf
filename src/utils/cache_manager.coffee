
class CacheManager

  storage = {}

  constructor: (@namespace = '_global') ->
    storage[@namespace] ?= {}
    @storage = storage[@namespace]

  set: (key, val) -> @storage[key] = val
  get: (key) -> @storage[key]

  clear: (key) ->
    storage[@namespace] = null
    @storage = null

