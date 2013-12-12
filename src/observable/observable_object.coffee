
class Leaf.ObservableObject extends Leaf.ObservableBase

  init: ->
    super()

    for own key, val of @_data
      @_data[key] = @_makeObservable val, @, key
      @_accessor key

