internalObjectData = require './internal_object_data'


bindContext = (fn, ctx, alt) ->
  prop = '_contextFunction'

  iod = internalObjectData fn, ctx

  if alt
    prop += "_#{alt._bindName}" if alt._bindName
    iod[prop] ?= alt
  else
    iod[prop] ?= fn.bind ctx


module.exports = bindContext
