_               = require 'lodash'
ObservableBase  = require './observable_base'
ObservableArray = require './observable_array'


class ObservableObject extends ObservableBase

  setData: (data = {}) ->
    @_data ?= {}
    @_set key, val for own key, val of data
    null

  toObject: -> _.clone @_data

  _makeObservable: (o) ->
    if o && o instanceof ObservableBase
      o
    else if _.isPlainObject o
      new ObservableObject o
    else if _.isArray o
      new ObservableArray o
    else
      o


module.exports = ObservableObject
