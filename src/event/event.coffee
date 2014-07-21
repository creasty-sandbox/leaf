class Event

  constructor: (data = {}) ->
    @name = ''
    @propagated = false
    @allowPropagation = true

    @[key] = val for own key, val of data when val?

  clone: ->
    new @constructor @

  stopPropagation: -> @allowPropagation = false


module.exports = Event
