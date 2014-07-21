_contextID = 0

getContextID = (o) -> (o.__contextID ?= ++_contextID)

bindContext = (fn, ctx, alt) ->
  id = getContextID ctx

  bindName = "__bind_#{id}"

  if alt
    bindName += "_#{alt._bindName}" if alt._bindName
    fn[bindName] ?= alt
  else
    fn[bindName] ?= fn.bind ctx

  true


module.exports = bindContext
