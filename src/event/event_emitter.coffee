_     = require 'lodash'
Event = require './event'


class EventEmitter

  WILD_CARD = '*'

  constructor: (eventObject = {}) ->
    @_callbacks = (eventObject.__callbacks ?= {})

  _getCallbacks: (event) ->
    @_callbacks[event] ?= []

  on: (event, handler) ->
    if !handler && _.isFunction event
      handler = event
      event = WILD_CARD

    @_getCallbacks(event).push handler
    @

  off: (event, handler) ->
    if !handler && _.isFunction event
      handler = event
      event = WILD_CARD

    if handler
      callbacks = @_getCallbacks event
      idx = callbacks.indexOf handler
      callbacks.splice idx, 1 if ~idx
    else
      @_callbacks[event] = []

    @

  once: (event, handler) ->
    fired = false

    unless handler.__once_fn
      _once = =>
        @off event, _once
        handler arguments...
      handler.__once_fn = _once

    @on event, handler.__once_fn ? handler
    @

  trigger: (event, args...) ->
    event = if event instanceof Event
        event.clone()
      else
        new Event name: event

    callbacks = @_getCallbacks event.callbacksName ? event.name
    wildCallbacks = @_getCallbacks WILD_CARD

    args.unshift event

    callback.apply null, args for callback in callbacks
    callback.apply null, args for callback in wildCallbacks

    @


module.exports = EventEmitter
