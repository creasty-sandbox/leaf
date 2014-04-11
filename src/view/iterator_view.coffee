
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
    @viewArray = new Leaf.ViewArray @$marker

    binder = new Leaf.Template.Binder @obj
    bindingObj = binder.getBindingObject @node.localeBindings

    @collection = bindingObj.get @node.iterator

    unless @collection instanceof Leaf.ObservableArray
      throw new NonIteratableObjectError @node.iterator, @collection

    @collection.forEach @addOne

    handler =
      insertAt: (i, element) =>
        view = @createView element
        @viewArray.insertAt i, view
      removeAt: (i) =>
        @viewArray.removeAt i
      swap: (i, j) =>
        @viewArray.swap i, j

    @collection.observe => @sync handler

  addOne: (item) =>
    view = @createView item
    @viewArray.push view

  createView: (item) ->
    id = "#{@_observableID}:#{item._observableID}"

    IteratorItemView.findOrCreate id, (klass) =>
      scope = @obj.syncedClone()
      scope.set @node.iterator, item, withoutDelegation: true

      new klass
        tree: @node.contents
        id: id
        obj: scope
      ,
        model: item
        collection: @collection


#  Iterator item
#-----------------------------------------------
class IteratorItemView extends Leaf.View


#  Registeration
#-----------------------------------------------
Leaf.Template.registerTag 'each', IteratorView

