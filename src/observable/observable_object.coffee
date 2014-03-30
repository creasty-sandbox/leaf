
class Leaf.ObservableObject extends Leaf.ObservableBase

  setData: (data = {}, accessor = true) ->
    @_data ?= {}
    @_set key, obj for own key, val of data
    null

  _delegateProperties: (o) ->
    @_delegated[key] = o._observableID for own key, val of o._data
    super o

