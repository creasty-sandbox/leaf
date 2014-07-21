_ = require 'lodash'


_include = (to, source = {}) ->
  return false unless _.isFunction(source) || _.isPlainObject(source)

  to[key] ?= val for own key, val of source
  true

include = (to, mixin) ->
  if mixin.includeAsMixin
    mixin.includeAsMixin to
  else
    _include to, mixin
    _include to::, mixin::

initMixin = (instance, mixin, args...) ->
  mixin.apply? instance, args


module.exports = { include, initMixin }
