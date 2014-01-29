
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
    @collectionViews = new Leaf.ObservableArray []

    binder = new Leaf.Template.Binder @obj
    bindingObj = binder.getBindingObject @node.localeBindings

    @collection = bindingObj.get @node.iterator

    unless @collection instanceof Leaf.ObservableArray
      throw new NonIteratableObjectError @node.iterator, @collection

    @collection.forEach @addOne
    @collection.observe @update

  addOne: (item) =>
    view = @createView item
    view.$view.insertBefore @$marker
    @collectionViews.push view

  createView: (item) ->
    id = "#{@node._nodeID}:#{item.toLeafID()}"

    IteratorItemView.findOrCreate id, (klass) =>
      scope = new Leaf.ObservableObject()
      scope.set @node.iterator, item
      scope.mergeWith @obj

      scope = @obj.cloneWithSameID()
      scope.set @node.iterator, item

      new klass
        tree: @node.contents
        obj: scope
      ,
        model: item
        collection: @collection

  update: (models) =>
    @applyPatch op for op in models.getPatch()

  applyPatch: ({ method, index, element }) ->
    console.log element
    switch method
      when 'insertAt'
        view = @createView element

        $idx = @collectionViews[index]?.$view ? @$marker

        view.$view.insertBefore $idx

        @collectionViews.insertAt index, [view]
      when 'removeAt'
        if (cv = @collectionViews[index])
          cv.detach()
          @collectionViews.removeAt index


#  Iterator item
#-----------------------------------------------
class IteratorItemView extends Leaf.View


#  Registeration
#-----------------------------------------------
Leaf.Template.registerTag 'each', IteratorView

