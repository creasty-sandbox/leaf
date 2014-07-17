
class Leaf.Collection extends Leaf.Object

  constructor: ->
    @_detachHandlers = {}
    @models = new Leaf.ObservableArray()
    super()

