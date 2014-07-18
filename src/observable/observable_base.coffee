_                   = require 'lodash'
Mixin               = require '../utils/mixin'
LeafID              = require '../utils/leaf_id'
Accessible          = require '../utils/accessible'
Event               = require '../event'
EventEmitter        = require '../event/event_emitter'
Keypath             = require './keypath'
KeypathEventTracker = require './keypath_event_tracker'


class ObservableBase

  _id = 0

  Accessible.ontoClass @

  Mixin.extend @, LeafID

  constructor: (@_data = {}) ->
    @id = ++_id
    @observableId = "#{@id}_observable"

    @_propagateHandlers = {}

    @_emitter = new EventEmitter()

    Keypath.sharedKeypath.addKey key for own key of @_data
    @_catchPropagatedEvents key for own key, obj of @_data when obj instanceof ObservableBase

  get: (key, id, chainId) ->
    event = new Event
      name:           'get'
      keypath:        key
      keypathId:      id
      keypathChainId: chainId

    @trigger event

    value = @_data[key]

    if _.isFunction value
      Keypath.sharedKeypath.beginChain()
      value = try value.call @
      Keypath.sharedKeypath.endChain()

    value

  trigger: ->
    @_emitter.trigger arguments...
    @

  on: ->
    @_emitter.on arguments...
    @

  once: ->
    @_emitter.once arguments...
    @

  off: ->
    @_emitter.off arguments...
    @

  _buildKeypath: (paths...) -> _.compact(paths).join '.'

  _catchPropagatedEvents: (key) ->
    return if @_propagateHandlers[key]
    obj = @_data[key]

    general = (e, args...) =>
      e = e.clone()
      e.propagated = true
      e.keypath = @_buildKeypath key, e.keypath
      e.keypathPropagatedPath = e.keypath.split('.')[0...-1].join '.'
      @trigger e, args...

    detach = (e) =>
      @unset @_buildKeypath(key, e.keypath)

    handler = @_propagateHandlers[key] = { general, detach }

    obj.on 'detach', handler.detach
    obj.on handler.general


  getEventTracker: (event) ->
    new KeypathEventTracker @, event


module.exports = ObservableBase
