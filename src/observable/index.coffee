_                = require 'lodash'
ObservableBase   = require './observable_base'
ObservableObject = require './observable_object'
ObservableArray  = require './observable_array'

Observable =
  make: (o, options = {}) ->
    if o && o instanceof ObservableBase
      o
    else if _.isPlainObject o
      new ObservableObject o, options
    else if _.isArray o
      new ObservableArray o, options
    else
      throw new TypeError()


module.exports = Observable
