_                = require 'lodash'
ObservableBase   = require './observable_base'
ObservableObject = require './observable_object'


class ObservableArray extends ObservableBase

  _makeObservable: (o) ->
    if o && o instanceof ObservableBase
      o
    else if _.isPlainObject o
      new ObservableObject o
    else if _.isArray o
      new ObservableArray o
    else
      o


module.exports = ObservableArray
