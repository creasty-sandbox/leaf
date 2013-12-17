
#  Iterator
#-----------------------------------------------
class IteratorView extends Leaf.Object

  @structure: true

  @open: (node, parent) ->
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

  @create: (node, $marker, $parent, obj) ->
    iv = new IteratorView()
    iv.init node, $marker, $parent, obj

  init: (@node, @$marker, @$parent, @obj) ->
    ite = @node.scope[@node.iterator]

    @collection = obj.get ite.expr
    @collectionViews = new Leaf.ObservableArray []

    @collection.forEach @addOne
    @collection.observe @update

  addOne: (item) =>
    view = @createView item
    view.$view.insertBefore @$marker
    @collectionViews.push view

  createView: (item) ->
    new IteratorItemView @node, item, @obj

  update: (models) =>
    @applyPatch op for op in models.getPatch()

  applyPatch: ({ method, index, element }) ->
    switch method
      when 'insertAt'
        view = @createView element

        $idx = @collectionViews[index]?.$view ? @$marker

        view.$view.insertBefore $idx

        @collectionViews.insertAt index, [view]
      when 'removeAt'
        if (cv = @collectionViews[index])
          cv._removeView()
          @collectionViews.removeAt index


#  Iterator item
#-----------------------------------------------
class IteratorItemView extends Leaf.View

  constructor: (@node, @item, @obj) ->
    return cached if (cached = @getCachedView @item)

    scope = {}
    scope[@node.iterator] = @item
    @$view = @fromParsedTree @node.contents, @obj, scope

    super @$view


#  Registeration
#-----------------------------------------------
Leaf.Template.registerTag 'each', IteratorView

