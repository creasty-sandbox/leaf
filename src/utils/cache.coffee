
class Leaf.Cache

  storage = _global: {}

  constructor: (@namespace = '_global') ->
    storage[@namespace] ?= {}
    @storage = storage[@namespace]

  set: (key, val) -> @storage[key] = val
  get: (key, set) -> (@storage[key] ?= set)

  clear: (key) ->
    storage[@namespace] = null
    @storage = null

