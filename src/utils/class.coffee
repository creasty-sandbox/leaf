
class Leaf.Class extends Object

  getclass: -> @constructor

  @singleton: ->
    instance = new @ arguments...
    instance._sharedinstance = instance
    instance

  @mixin: -> _mixin @, arguments...
  mixin: -> _mixin @, arguments...
  initMixin: (mixins...) ->
    mixin.apply @ for mixin in mixins ? []

  _mixin = (to, mixins...) ->
    for mixin in mixins
      continue unless _.isFunction(mixin) || _.isPlainObject(mixin)

      to[key] ?= value for key, value of mixin when key != 'prototype'
      to::[key] ?= value for key, value of mixin:: ? {}

    to

