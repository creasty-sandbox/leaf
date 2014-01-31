
class Leaf.ObservableObject extends Leaf.ObservableBase

  _initWithData: (data = {}) ->
    @_data = {}

    for own key, val of data
      obj = @_makeObservable val, @, key
      @_data[key] = obj
      @_accessor key

    null

  _delegateProperties: (o) ->
    for own key, val of o._data
      @_delegated[key] = o._observableID

    oid = o.toLeafID()
    o._observe null, (val, id, prop) =>
      @_update prop, val unless id == oid

    null

  createDelegatedClone: ->
    o = @clone()
    o._delegateProperties @
    o

