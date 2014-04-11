
#  Error
#-----------------------------------------------
class NoIteratorBindingsError extends Leaf.Error
class NonIteratableObjectError extends Leaf.Error

  setMessage: (iterator, obj) ->
    "`#{iterator}` is #{Object::toString.call obj}"


#  Iterator
#-----------------------------------------------
class ViewArray

  constructor: (@$head) ->
    @_views = []

  push: (view) ->
    view.insertAfter @$head
    @_views.push view.$view

  insertAt: (index, view) ->
    if ($idx = @_views[index])
      view.$view.insertBefore $idx
    else
      view.$view.insertAfter @$head

    @_views.splice index, -1, view

  removeAt: (index) ->
    view = @_views[index]
    view.detach()
    @_views.splice index

  swap: (i, j) ->
    vi = @_views[i]
    vj = @_views[j]

    vi.insertBefore vj

    vi = @_views[i]
    vj.insertBefore vi

    tmp = @_views[i]
    @_views[i] = @_views[j]
    @_views[j] = tmp


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
    @viewArray = new ViewArray @$marker

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

