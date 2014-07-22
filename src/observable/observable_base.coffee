_                   = require 'lodash'
typePattern         = require '../utils/type_pattern'
bindContext         = require '../utils/bind_context'
BaseClass           = require '../mixins/base_class'
LeafID              = require '../mixins/leaf_id'
Accessible          = require '../mixins/accessible'
Event               = require '../event'
EventEmitter        = require '../event/event_emitter'
Keypath             = require './keypath'
KeypathEvent        = require './keypath_event'
KeypathEventTracker = require './keypath_event_tracker'


class ObservableBase

  BaseClass.make @

  @setClassName 'ObservableBase'

  @mixin Accessible
  @mixin LeafID
  @mixin EventEmitter

  constructor: (data) ->
    @_dependents = {}
    @_delegates = {}
    @_propagateHandlers = {}

    @_inBatch = 0

    @initMixin LeafID
    @initMixin EventEmitter

    @_cachedValues = {}

    @_observers = {}

    @setupPrivateEventResolvers()
    @setData data

  setData: (data) ->

  _makeObservable: (o) ->


  #  Accessor
  #-----------------------------------------------
  _getComputedValue: (key, fn) ->
    dependents = []
    value = null

    Keypath.sharedKeypath.chain =>
      dependents = @trackEvent 'get', =>
        value = try fn.call @

    handlers = (@_dependents[key] ?= {})

    dependents.forEach (dependent) =>
      return if handlers[dependent]

      handlers[dependent] = (e) =>
        event = new KeypathEvent
          name:    'update'
          keypath: key

        oldValue = @_cachedValues[key]
        newValue = fn.call @
        @_cachedValues[key] = newValue
        @trigger event, newValue, oldValue

      @observe dependent, handlers[dependent]

    value

  _get: (key) ->
    return @ unless key?

    return @_delegates[key].obj._get key if @_delegates[key]

    event = new KeypathEvent
      name:    'get'
      keypath: key

    @trigger event

    value = @_data[key]
    value = @_getComputedValue key, value if _.isFunction value
    @_cachedValues[key] = value

    value

  get: (keypath) ->
    { obj, key } = @getTerminalObjectForKeypath keypath
    obj?._get key

  _set: (key, val, options = {}) ->
    return unless key

    if (delegate = @_delegates[key])
      if options.withoutDelegation
        @undelegate key
      else
        return delegate.obj._set key, val, options

    Keypath.sharedKeypath.addKey key

    if _.isFunction @_data[key]
      oldValue = @_cachedValues[key]
      newValue = oldValue
      Keypath.sharedKeypath.chain =>
        newValue = @_data[key].call @, val
        @_cachedValues[key] = newValue
    else
      oldValue = @_data[key]
      newValue = @_makeObservable val

      unless newValue == oldValue
        @_uncatchPropagatedEvents key
        @_data[key] = newValue
        @_catchPropagatedEvents key

    if (options.notify ? true) && newValue != oldValue
      e = new KeypathEvent
        name:    'set'
        keypath: key

      @trigger e, newValue, oldValue

    newValue

  set: ->
    { keypath, val, options, pairs } = typePattern
      'oo?':  'pairs options'
      's.o?': 'keypath val options'
    , arguments

    if pairs
      for own k, v of pairs
        if _.isPlainObject v
          @get(k)?.set v, options
        else
          @set k, v, options

      return @

    { obj, key } = @getTerminalObjectForKeypath keypath, options?.withoutDelegation

    obj?._set key, val, options

  _unset: (key, options) ->
    @_set key, undefined, options

  unset: (keypath, options) ->
    { obj, key } = @getTerminalObjectForKeypath keypath
    obj?._unset key, options


  #  Keypath
  #-----------------------------------------------
  getTerminalObjectForKeypath: (keypath, withoutDelegation) ->
    keypath = Keypath.regulate keypath

    path = keypath.split '.'
    len = path.length

    key = path.pop()
    obj = @

    if len > 1
      while obj instanceof ObservableBase && (p = path.shift())
        obj =
          if withoutDelegation
            obj._data[p]
          else
            obj = obj._delegates[p]?.obj._data[p] ? obj._data[p]
    else if !withoutDelegation
      obj = @_delegates[key]?.obj ? @

    { obj, key }


  #  Batch
  #-----------------------------------------------
  batch: (fn) ->
    ++@_inBatch
    keypaths = @trackEvent 'set', fn
    --@_inBatch

    _(keypaths).forEach (keypath) =>
      event = new KeypathEvent
        name:    'set'
        keypath: keypath

      @trigger event, @_get(keypath)


  #  Event
  #-----------------------------------------------
  setupPrivateEventResolvers: ->
    handler = (e, args...) =>
      return if @_inBatch

      # event = e.clone()
      # event.callbacksName = "#{e.name}@#{keypath}"

      if (observers = @_observers['*'])
        event = e.clone()
        observer event, args... for observer in observers

      for keypath in Keypath.ancestors e.keypath
        if (observers = @_observers[keypath])
          event = e.clone()
          observer event, args... for observer in observers

    @on 'set', handler
    @on 'update', handler

  trigger: (event, args...) ->
    unless event instanceof KeypathEvent
      event =
        if event instanceof Event
          new KeypathEvent event
        else
          new KeypathEvent name: event

    EventEmitter::trigger.apply @, arguments

  _catchPropagatedEvents: (key) ->
    return if @_propagateHandlers[key]

    obj = @_data[key]

    return unless obj instanceof ObservableBase

    general = (e, args...) =>
      return unless e.allowPropagation
      e = e.clone()
      e.propagated = true
      e.keypath = Keypath.build key, e.keypath
      @trigger e, args...

    detach = (e) =>
      @unset Keypath.build(key, e.keypath)

    handler = @_propagateHandlers[key] = { general, detach }

    obj.on 'detach', handler.detach
    obj.on handler.general

  _uncatchPropagatedEvents: (key) ->
    return unless @_propagateHandlers[key]

    obj = @_data[key]
    handler = @_propagateHandlers[key]

    @_propagateHandlers[key] = null
    obj.off 'detach', handler.detach
    obj.off handler.general

  trackEvent: (event, fn) ->
    tracker = new KeypathEventTracker @, event
    tracker.track fn


  #  Notify update
  #-----------------------------------------------
  _update: (key) ->
    e = new KeypathEvent
      name:    'update'
      keypath: key

    @trigger e

  update: (keypath) ->
    { obj, key } = @getTerminalObjectForKeypath keypath
    obj?._update key

  observe: ->
    { keypath, callback } = typePattern
      's?f': 'keypath callback'
    , arguments

    observers = (@_observers[keypath ? '*'] ?= [])
    observers.push callback
    @

  unobserve: ->
    { keypath, callback } = typePattern
      's?f': 'keypath callback'
    , arguments

    observers = (@_observers[keypath ? '*'] ?= [])
    index = observers.indexOf callback
    observers.splice index, 1 if ~index
    @


  #  Clone
  #-----------------------------------------------
  clone: ->
    o = new @constructor @_data
    o.set key, @_get(key) for own key of @_delegates when obj
    o

  syncedClone: ->
    o = new @constructor()
    o.delegate key, @ for own key of @_data
    o.delegate key, obj.obj for own key, obj of @_delegates when obj
    o


  #  Delegation
  #-----------------------------------------------
  delegate: (key, obj) ->
    delegate =
      obj: obj
      handler: => @trigger arguments...

    @undelegate key

    Keypath.sharedKeypath.addKey key
    @_delegates[key] = delegate
    delegate.obj.on delegate.handler

  undelegate: (key) ->
    return unless (delegate = @_delegates[key])
    @_delegates[key] = null
    delegate.obj.off delegate.handler


  #  Detach / destroy
  #-----------------------------------------------
  detach: ->
    @trigger 'detach', @

  destroy: ->
    @detatch()
    @trigger 'destroy', @
    @_destroy()

  _destroy: ->
    @_data = null


module.exports = ObservableBase
