
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
    unless node.localeBindings.condition
      throw new Error 'Parse error: if should have $condition'

    cond = node.localeBindings.condition
    stack = ["(#{cond.expr})"]

    node.condition =
      stack: stack
      expr: stack.join '&&'
      vars: cond.vars

    parent.context.if = node

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init node.contents, obj
    $el = view.getDOM()
    binder = view.bind node.condition

    binder (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()

#  elseif
#-----------------------------------------------
Leaf.Template.registerTag 'elseif',
  structure: true

  open: (node, parent) ->
    unless parent.context.if
      throw new Error 'Context error: cannot resolve elseif'

    unless node.localeBindings.condition
      throw new Error 'Parse error: if should have $condition'

    cond = node.localeBindings.condition

    n = parent.context.if
    stack = n.condition.stack
    prev = stack.pop()
    stack.push '!' + prev
    stack.push "(#{cond.expr})"

    node.condition =
      stack: stack
      expr: stack.join '&&'
      vars: _.union n.condition.vars, cond.vars

    parent.context.if = node

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init node.contents, obj
    $el = view.getDOM()
    binder = view.bind node.condition

    binder (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()

#  else
#-----------------------------------------------
Leaf.Template.registerTag 'else',
  structure: true

  open: (node, parent) ->
    unless parent.context.if
      throw new Error 'Context error: cannot resolve else'

    n = parent.context.if
    stack = n.condition.stack
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
    binder = view.bind node.condition

    binder (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()


