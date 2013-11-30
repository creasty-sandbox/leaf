
class ObservableArray extends ObservableBase

  constructor: (data, parent, parent_key) ->
    data.__proto__ = ObservableArray::
    data.init data, parent, parent_key
    return data

  _.extend @::, new Array

  init: (@_data, @_parent, @_parent_key) ->
    super()
    @_observed = []

    i = 0
    @_observed.push @_makeObservable(val, @, i++) for val in @

  cls = @

  ['push', 'concat', 'reverse', 'unshift', 'sort']
  .forEach (method) ->
    cls::[method] = (args...) ->
      Array::[method].apply @, args
      @_update()
      @

  ['pop', 'shift', 'splice']
  .forEach (method) ->
    cls::[method] = (args...) ->
      res = Array::[method].apply @, args
      @_update()
      res

  removeAt: (index) ->
    @splice index, 1
    @

  insertAt: (index, element) ->
    @splice index, 0, element...
    @

