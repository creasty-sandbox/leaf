
_.mixin bindContext: do ->

  _contextID = 0

  getContextIDForContext = (ctx, name = 'context') ->
    id = (ctx._contextID ?= ++_contextID)
    "__bind_#{contex}_#{id}"

  (fn, ctx, contextName, altfn) ->
    id = getContextIDForContext ctx, contextName
    fn[id] ?= altfn ? fn.bind ctx

