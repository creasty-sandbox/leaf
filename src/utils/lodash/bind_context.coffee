
_.mixin bindContext: do ->

  _contextID = 0

  getContextIDForContext = (ctx, contextName = 'context') ->
    id = (ctx._contextID ?= ++_contextID)
    "__bind_#{contextName}_#{id}"

  (fn, ctx, contextName, altfn) ->
    id = getContextIDForContext ctx, contextName
    fn[id] ?= altfn ? fn.bind ctx

