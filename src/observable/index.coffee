_                = require 'lodash'
ObservableBase   = require './observable_base'
ObservableObject = require './observable_object'
ObservableArray  = require './observable_array'


make = (o) ->
  if o && o instanceof ObservableBase
    o
  else if _.isPlainObject o
    new ObservableObject o
  else if _.isArray o
    new ObservableArray o
  else
    throw new TypeError()


module.exports = { make }
