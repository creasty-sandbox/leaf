_ = require 'lodash'


include = (to, source = {}) ->
  return false unless _.isFunction(source) || _.isPlainObject(source)

  to[key] ?= val for key, val of source when key != 'prototype'
  true

extend = (to, klass) ->
  include to, klass
  include to::, klass::

initMixin = (instance, mixins...) ->
  for mixin in mixins when mixin
    if _.isArray mixin
      fn = mixin.shift()
      fn.apply instance, mixin
    else
      mixin.apply instance

  true


module.exports = { include, extend, initMixin }
