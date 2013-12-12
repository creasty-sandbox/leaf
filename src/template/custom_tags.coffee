
#  if ... elseif ... else
#-----------------------------------------------
Leaf.Template.registerTag 'if',
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

    node.condition = node.localeBindings.condition
    node.localeBindings.condition = undefined
    node.scope.condition = undefined
    parent.context.if = node

Leaf.Template.registerTag 'else',
  open: (node, parent) ->
    unless parent.context.if
      throw new Error 'Context error: cannot resolve else'

    n = parent.context.if
    node.condition = "!(#{n.condition})"
    parent.context.if = null

Leaf.Template.registerTag 'elseif',
  open: (node, parent) ->
    unless parent.context.if
      throw new Error 'Context error: cannot resolve elseif'

    unless node.localeBindings.condition
      throw new Error 'Parse error: if should have $condition'

    node.condition = node.localeBindings.condition
    node.localeBindings.condition = undefined
    node.scope.condition = undefined

    n = parent.context.if
    node.condition = "!(#{n.condition}) && (#{node.condition})"
    parent.context.if = node


#  each
#-----------------------------------------------
Leaf.Template.registerTag 'each',
  open: (node, parent) ->
    node.iterators = []

    for key, val of node.localeBindings when val.match /\w+\[\]/
      ik = "#{key}Index"
      val = val.replace '[]', "[#{ik}]"
      node.localeBindings[key] = undefined
      node.scope[key] = val
      node.iterators.push ik

    unless node.iterators.length
      throw new Error 'Parse error: each should have one or more iterators'


