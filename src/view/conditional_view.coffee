
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

    stack = ["(#{condition.expr})"]

    node.condition =
      stack: stack
      expr: stack.join '&&'
      vars: condition.vars

    parent.context.if = node

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init node.contents, obj
    $el = view.getDOM()
    bind = view.getBinder node.condition

    bind (result) ->
      if !!result
        $el.insertAfter $marker
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
    stack.push "(#{condition.expr})"

    node.condition =
      stack: stack
      expr: stack.join '&&'
      vars: _.union n.condition.vars, condition.vars

    parent.context.if = node

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init node.contents, obj
    $el = view.getDOM()
    bind = view.getBinder node.condition

    bind (result) ->
      if !!result
        $el.insertAfter $marker
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
      vars: n.condition.vars

    parent.context.if = null

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init node.contents, obj
    $el = view.getDOM()
    bind = view.getBinder node.condition

    bind (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()


