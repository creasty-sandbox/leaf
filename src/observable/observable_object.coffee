
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

    fn = (val, id, prop) =>
      @_set prop, val, notify: false if id == oid

    fn._dependentHandler = true
    o._observe null, fn

  createDelegatedClone: ->
    o = @clone()
    o._delegateProperties @
    o

