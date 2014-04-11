
class Leaf.ObservableObject extends Leaf.ObservableBase

  setData: (data = {}, accessor = true) ->
    @_data ?= {}
    @_set key, val for own key, val of data
    null

  toObject: -> _.clone @_data

