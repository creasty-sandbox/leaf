
class Leaf.ObservableObject extends Leaf.ObservableBase

  init: ->
    super()

    _data = @_data
    @_data = {}

    for own key, val of _data
      obj = @_makeObservable val, @, key
      @_data[key] = obj
      @_accessor key

