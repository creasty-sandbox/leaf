
class ObservableObject extends ObservableBase

  init: ->
    super()
    @_observed = {}

    for own key, val of @_data
      @_observed[key] = @_makeObservable val, @, key
      @_accessor key

