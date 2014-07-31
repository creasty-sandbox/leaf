internalProperty = require './internal_property'


bindContext = (fn, ctx, alt) ->
  prop = '_contextFunction'

  ip = internalProperty fn, ctx

  if alt
    prop += "_#{alt._bindName}" if alt._bindName
    ip.iset prop, alt
  else
    ip.iset prop, fn.bind(ctx)


module.exports = bindContext
