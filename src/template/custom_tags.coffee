
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
    view = new Leaf.Template.DOMGenerator()
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
    view = new Leaf.Template.DOMGenerator()
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
    view = new Leaf.Template.DOMGenerator()
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
class IteratedItemView extends Leaf.Object
  constructor: (@item, @obj, @tree, @iteratorName) ->
    @_viewCache = new Leaf.Cache 'views'
    cachedView = @_viewCache.get @item.toLeafID()

    return cachedView if cachedView
    @_viewCache.set @item.toLeafID(), @

    @_objectBaseInit()
    @init()

  init: ->
    view = new Leaf.Template.DOMGenerator()
    scope = {}
    scope[@iteratorName] = @item
    view.init _.cloneDeep(@tree), @obj, scope
    @$view = view.getDOM()

  destroy: ->
    @$view.detach()


Leaf.Template.registerTag 'each',
  structure: true

  open: (node, parent) ->
    node.iterator = null

    for key, value of node.localeBindings when value.expr.match /\w+\[\]$/
      ik = "#{key}Index"
      value.expr = value.expr.replace '[]', ''
      value.vars.push ik

      node.localeBindings[key] = undefined
      node.scope[key] = value
      node.iterator = key
      break

    unless node.iterator
      throw new Error 'Parse error: each should have one or more iterators'

  create: (node, $marker, $parent, obj) ->
    ite = node.scope[node.iterator]
    collection = obj.get ite.expr
    collectionViews = new Leaf.ObservableArray []

    createView = (item) ->
      new IteratedItemView item, obj, node.contents, node.iterator

    collection.forEach (item) ->
      view = createView item
      view.$view.insertBefore $marker
      collectionViews.push view

    collection.observe (models) ->
      for op in models.getPatch()
        switch op.method
          when 'insertAt'
            view = createView op.element

            if (indexView = collectionViews[op.index])
              view.$view.insertBefore indexView.$view
            else
              view.$view.insertBefore $marker

            collectionViews.insertAt op.index, [view]
          when 'removeAt'
            console.log collectionViews
            if (view = collectionViews[op.index])
              view.destroy()
              collectionViews.removeAt op.index

