
class Leaf.Cache

  storage = _global: {}

  constructor: (@namespace = '_global') ->
    storage[@namespace] ?= {}
    @storage = storage[@namespace]

  set: (key, val) -> @storage[key] = val
  get: (key, set) ->
    if "#{key}"[0...4] == 'UUID'
      @storage[key] ?= set
    else
      key

  clear: (key) ->
    storage[@namespace] = null
    @storage = null

