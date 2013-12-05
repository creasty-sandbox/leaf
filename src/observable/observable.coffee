
class Leaf.Observable

  constructor: (data) ->
    data = Leaf.ObservableBase::_makeObservable data
    return data

