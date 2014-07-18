singleton = (klass, name = 'Instance') ->
  name = "shared#{name}"

  _shared = null

  Object.defineProperty klass, name,
    enumerable:   true
    configurable: false

    get: -> _shared ?= new klass()

  true


module.exports = singleton
