
class Leaf.Event extends Leaf.Cacheable

  __event: true

  constructor: (obj) ->
    super()
    obj ?= @
    @_eventObj = $ obj

  on: (event, handler, ctx = global) ->
    @_eventObj.on event, (e, args...) ->
      handler.apply ctx, args

  off: (event, handler) ->
    @_eventObj.on event, handler

  one: (event, handler, ctx = global) ->
    @_eventObj.one event, (e, args...) ->
      handler.apply ctx, args

  trigger: (event, args...) ->
    @_eventObj.trigger event, args...

  delegate: ->
  undelegate: ->

  fire: ->

