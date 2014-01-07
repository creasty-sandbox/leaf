
class Leaf.Class extends Object

  @setLeafClass: (name = @name) -> @_objectType = name

  getLeafClass: -> "Leaf.#{@constructor._objectType}"

  @singleton: ->
    instance = new @ arguments...
    instance._sharedInstance = instance
    instance

  getClass: -> @constructor

  @_mixins: []

  @mixin: -> @_mixins.push mixinTo(@, mixin) for mixin in arguments
  mixin: -> mixinTo(@, mixin) for mixin in arguments

  initMixin: (mixin, args = []) -> mixin.apply @, args
  initMixins: -> @initMixin mixin for mixin in @constructor._mixins

  mixinTo = (to, mixin) ->
    return mixin unless _.isFunction(mixin) || _.isPlainObject(mixin)

    to[key] ?= value for key, value of mixin when key != 'prototype'
    to::[key] ?= value for key, value of mixin:: ? {}

    mixin

