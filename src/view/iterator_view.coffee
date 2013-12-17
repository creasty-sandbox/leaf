
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

