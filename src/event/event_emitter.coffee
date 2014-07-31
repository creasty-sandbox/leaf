_                  = require 'lodash'
internalObjectData = require '../utils/internal_object_data'
Event              = require './event'


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
    iod = internalObjectData handler, @
    iod['eventEmitter:once'] = true
    @on event, handler
    @

  _fire: (callbacks, handler, args) ->
    iod = internalObjectData handler, @

    if iod['eventEmitter:once']
      iod['eventEmitter:once'] = false
      idx = callbacks.indexOf handler
      callbacks.splice idx, 1 if ~idx

    handler.apply null, args

  trigger: (event, args...) ->
    event =
      if event instanceof Event
        event.clone()
      else
        new Event name: event

    callbacks = @_getCallbacks event.callbacksName ? event.name
    wildCallbacks = @_getCallbacks WILD_CARD

    args.unshift event

    @_fire callbacks, callback, args for callback in callbacks
    @_fire wildCallbacks, callback, args for callback in wildCallbacks

    @


module.exports = EventEmitter
