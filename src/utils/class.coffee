
class Leaf.Class extends Object

  @setLeafClass: (name = @name) -> @_objectType = name

  getLeafClass: -> "Leaf.#{@constructor._objectType}"

  @singleton: ->
    instance = new @ arguments...
    instance._sharedInstance = instance
    instance

  getClass: -> @constructor

  @mixin: ->
    @_mixins ?= []
    @_mixins.push mixinTo(@, mixin) for mixin in arguments
    null

  mixin: ->
    mixinTo(@, mixin) for mixin in arguments
    null

  initMixin: (mixins...) ->
    for mixin in mixins when mixin
      if _.isArray mixin
        fn = mixin.shift()
        fn.apply @, mixin
      else
        mixin.apply @

    null

  mixinTo = (to, mixin) ->
    return mixin unless _.isFunction(mixin) || _.isPlainObject(mixin)

    to[key] ?= value for key, value of mixin when key != 'prototype'
    to::[key] ?= value for key, value of mixin:: ? {}

    mixin

