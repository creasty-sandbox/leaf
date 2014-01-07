
class HookFunctionNotExistError extends Leaf.Error


class Hookable

  @_hooks = {}

  @beforeAction: (action, hook) -> @hook "beforeAction:#{action}", hook
  @afterAction: (action, hook) -> @hook "afterAction:#{action}", hook

  @hook: (name, hook) ->
    return unless name

    hook = @::[hook] if _.isString hook

    unless _.isFunction hook
      throw new HookFunctionNotExistError()

    name = name.split ':'

    while name[0]
      n = name.join ':'
      @_hooks[n] ?= []
      @_hooks[n].push hook
      name.pop()

  doBeforeHooks: (action) -> @doHooks "beforeAction:#{action}"
  doAfterHooks: (action) -> @doHooks "afterAction:#{action}"

  doHooks: (name) ->
    hooks = @_hooks[name] ? []

    break for hook in hooks when hook.call(@) == false

