
Leaf.Observable = (data) ->
  if _.isArray data
    new Leaf.ObservableArray data
  else if _.isPlainObject data
    new Leaf.ObservableObject data
  else
    data

