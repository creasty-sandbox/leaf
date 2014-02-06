
#  Error
#-----------------------------------------------
class NoIteratorBindingsError extends Leaf.Error
class NonIteratableObjectError extends Leaf.Error

  setMessage: (iterator, obj) ->
    "`#{iterator}` is #{Object::toString.call obj}"


#  Iterator
#-----------------------------------------------
class IteratorView extends Leaf.Object

  @structure: true

  @open: (node, parent) ->
    node.iterator = null

    for key, value of node.localeBindings when value.expr.match /\w+\[\]$/
      value.expr = value.expr.replace '[]', ''
      node.iterator = key
      break

    unless node.iterator
      throw new NoIteratorBindingsError()

  @create: (node, $marker, $parent, obj) ->
    iv = new IteratorView()
    iv.init node, $marker, $parent, obj

  init: (@node, @$marker, @$parent, @obj) ->
    @collectionViews = []

    binder = new Leaf.Template.Binder @obj
    bindingObj = binder.getBindingObject @node.localeBindings

    @collection = bindingObj.get @node.iterator

    unless @collection instanceof Leaf.ObservableArray
      throw new NonIteratableObjectError @node.iterator, @collection

    @collection.forEach @addOne
    @collection.observe => @applyPatch @collection.getPatch()

  addOne: (item) =>
    view = @createView item
    view.$view.insertBefore @$marker
    @collectionViews.push view

  createView: (item) ->
    id = "#{@_observableID}:#{item._observableID}"

    IteratorItemView.findOrCreate id, (klass) =>
      scope = @obj.delegatedClone()
      scope.set @node.iterator, item, overrideDelegate: true

      new klass
        tree: @node.contents
        id: id
        obj: scope
      ,
        model: item
        collection: @collection

  applyPatch: (patch) ->
    for p in patch
      switch p.method
        when 'insertAt'
          view = @createView p.element
          $idx = @collectionViews[p.index]?.$view ? @$marker
          view.render $idx
          @collectionViews.splice p.index, -1, view
        when 'removeAt'
          if view = @collectionViews[p.index]
            view.detach()
            @collectionViews.splice p.index, 1


#  Iterator item
#-----------------------------------------------
class IteratorItemView extends Leaf.View


#  Registeration
#-----------------------------------------------
Leaf.Template.registerTag 'each', IteratorView

