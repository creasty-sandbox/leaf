
#  Error
#-----------------------------------------------
class NoConditionBindingsParseError extends Leaf.Error
class InvalidIfContextError extends Leaf.Error


#  if
#-----------------------------------------------
Leaf.Template.registerTag 'if',
  structure: true

  reset: (node, parent) ->
    parent.context.if = null

  openOther: (node, parent) ->
    return if node.name == 'elseif' || node.name == 'else'
    parent.context.if = null

  closeOther: (node, parent) ->
    return if node.name == 'elseif' || node.name == 'else'
    parent.context.if = null

  open: (node, parent) ->
    { condition } = node.localeBindings

    unless condition
      throw new NoConditionBindingsParseError()

    stack = ["(#{condition})"]

    node.condition =
      stack: stack
      expr: stack.join '&&'

    parent.context.if = node

  create: (viewData) ->
    view = new Leaf.Template.DOMGenerator viewData.node.contents, viewData.controller, viewData.scope
    $el = view.getDOM()

    viewData.compiler.bind viewData.node.condition.expr, (result) ->
      if !!result
        $el.insertAfter viewData.$marker
      else
        $el.detach()

#  elseif
#-----------------------------------------------
Leaf.Template.registerTag 'elseif',
  structure: true

  open: (node, parent) ->
    n = parent.context.if

    unless n
      throw new InvalidIfContextError()

    { condition } = node.localeBindings

    unless condition
      throw new NoConditionBindingsParseError()

    { stack } = n.condition
    prev = stack.pop()
    stack.push '!' + prev
    stack.push "(#{condition})"

    node.condition =
      stack: stack
      expr: stack.join '&&'

    parent.context.if = node

  create: (viewData) ->
    view = new Leaf.Template.DOMGenerator viewData.node.contents, viewData.controller, viewData.scope
    $el = view.getDOM()

    view.compiler.bind viewData.node.condition.expr, (result) ->
      if !!result
        $el.insertAfter viewData.$marker
      else
        $el.detach()

#  else
#-----------------------------------------------
Leaf.Template.registerTag 'else',
  structure: true

  open: (node, parent) ->
    n = parent.context.if

    unless n
      throw new InvalidIfContextError()

    { stack } = n.condition
    prev = stack.pop()
    stack.push '!' + prev

    node.condition =
      stack: stack
      expr: stack.join '&&'

    parent.context.if = null

  create: (viewData) ->
    view = new Leaf.Template.DOMGenerator viewData.node.contents, viewData.controller, viewData.scope
    $el = view.getDOM()

    viewData.compiler.bind viewData.node.condition.expr, (result) ->
      if !!result
        $el.insertAfter viewData.$marker
      else
        $el.detach()


