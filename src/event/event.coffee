class Event

  constructor: (data = {}) ->
    @name = ''
    @propagated = false

    @[key] = val for own key, val of data when val?

  clone: ->
    new @constructor @


module.exports = Event

