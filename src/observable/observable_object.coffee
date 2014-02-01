
class Leaf.ObservableObject extends Leaf.ObservableBase

  setData: (data = {}) ->
    @_data = {}

    for own key, val of data
      obj = @_makeObservable val, @, key
      @_data[key] = obj
      @_accessor key

    null

  _delegateProperties: (o) ->
    @_delegated[key] = o._observableID for own key, val of o._data
    super o

