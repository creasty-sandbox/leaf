
#  Error
#-----------------------------------------------
class NoIteratorBindingsError extends Leaf.Error
class NonIteratableObjectError extends Leaf.Error

  setMessage: (iterator, obj) ->
    "`#{iterator}` is #{Object::toString.call obj}"


#  Iterator
#-----------------------------------------------
class IteratorView

  COLLECTION_BINDING = '$collection'

  @structure: true

  @open: (node, parent) ->
    node.iterator = null

    for key, value of node.localeBindings when value.match /\w+\[\]$/
      node.iterator = key
      node.localeBindings[key] = null
      node.localeBindings[COLLECTION_BINDING] = value.replace '[]', ''
      return

    throw new NoIteratorBindingsError()

  @create: (viewData) -> new IteratorView viewData

  constructor: (@viewData) ->
    @viewArray = new Leaf.ViewArray @viewData.$marker

    @collection = @viewData.scope.get COLLECTION_BINDING

    unless @collection instanceof Leaf.ObservableArray
      throw new NonIteratableObjectError COLLECTION_BINDING, @collection

    @collection.forEach (item) =>
      view = @createView item
      @viewArray.push view

    handler =
      insertAt: (i, element) =>
        view = @createView element
        @viewArray.insertAt i, view
      removeAt: (i) =>
        @viewArray.removeAt i
      swap: (i, j) =>
        @viewArray.swap i, j

    @collection.observe => @collection.sync handler

  createView: (item) ->
    id = "iteratorItemView:#{@_leafID}:#{item._leafID}"

    Leaf.Cache.findOrCreate id, =>
      { iterator } = @viewData.node
      scope = @viewData.scope.syncedClone()
      scope.set iterator, item, withoutDelegation: true
      scope.set "$#{iterator}Index", 0

      new Leaf.View
        tree:       @viewData.node.contents
        controller: @viewData.controller
        scope:      scope


#  Registeration
#-----------------------------------------------
Leaf.Template.registerTag 'each', IteratorView

