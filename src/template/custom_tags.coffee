
#  if ... elseif ... else
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
    view = new Leaf.Template.View()
    view.init node.contents, obj
    $el = view.getDOM()
    binder = view.bind node.condition

    binder (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()

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
    view = new Leaf.Template.View()
    view.init node.contents, obj
    $el = view.getDOM()
    binder = view.bind node.condition

    binder (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()

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
    view = new Leaf.Template.View()
    view.init node.contents, obj
    $el = view.getDOM()
    binder = view.bind node.condition

    binder (result) ->
      if !!result
        $el.insertAfter $marker
      else
        $el.detach()


#  each
#-----------------------------------------------
Leaf.Template.registerTag 'each',
  structure: true

  open: (node, parent) ->
    node.iterator = null

    for key, value of node.localeBindings when value.expr.match /\w+\[\]/
      ik = "#{key}Index"
      value.expr = value.expr.replace '[]', "[#{ik}]"
      value.vars.push ik

      node.localeBindings[key] = undefined
      node.scope[key] = value
      node.iterator = value
      break

    unless node.iterator
      throw new Error 'Parse error: each should have one or more iterators'

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.View()
    view.init node.contents, obj
    $el = view.getDOM()
    binder = view.bind node.iterator

    binder (result) ->
    ###
    for i in [0...collection.length] by 1
      view = new modelview collection[i], collection
      view.$view.appendTo $container

    collection.observe (models) ->
      for op in models.getPatch()
        switch op.method
          when 'insertAt'
            index = op.args[0]
            added = op.args[1][0]
            view = new modelview added, collection

            if (indexView = collection.views[index])
              view.$view.insertBefore indexView.$view
            else
              view.$view.appendTo $container

            collection.views.insertAt index, [view]
          when 'removeAt'
            index = op.args[0]
            if view = collection.views[index]
              view.destroy()
              collection.views.removeAt index
    ###

