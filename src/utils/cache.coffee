
class Leaf.Cache

  storage = _global: {}

  constructor: (@namespace = '_global') ->
    storage[@namespace] ?= {}
    @storage = storage[@namespace]

  get: (key, set) -> (@storage[key] ?= set)

  set: (key, val, override = false) ->
    return if !override && @storage[key]?
    @storage[key] = val

  unset: (key) -> @set key, undefined, true

  clear: (key) ->
    storage[@namespace] = null
    @storage = null

