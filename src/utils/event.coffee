
class Leaf.Event

  constructor: (eventObject = {}) ->
    eventObject._$ ?= $ eventObject
    @_eventObject = eventObject._$

  on: (event, handler, ctx = Leaf.context) ->
    handler = _.bindContext handler, ctx, 'event', (e, args...) ->
      handler.apply ctx, args

    @_eventObject.on event, handler[id]

  off: (event, handler, ctx = Leaf.context) ->
    id = @_getContextIDForContext ctx

    @_eventObject.off event, handler[id] ? handler

  one: (event, handler, ctx = Leaf.context) ->
    id = @_getContextIDForContext ctx

    handler[id] ?= (e, args...) ->
      handler.apply ctx, args

    @_eventObject.one event, handler[id]

  trigger: (event, args...) ->
    @_eventObject.trigger event, args...


Leaf.sharedEvent = new Leaf.Event Leaf

