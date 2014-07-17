
class Leaf.ObservableBase extends Leaf.Class

  __observable: true

  @mixin Leaf.Cacheable, Leaf.Accessible

  constructor: (data) ->
    @initMixin Leaf.Cacheable, Leaf.Accessible

    @_dependents = {}
    @_tracked = {}
    @_tracking = {}
    @_delegates = {}
    @_propagateHandlers = {}

    @_emitter = new Leaf.EventEmitter()

    @compiler = new Leaf.ExpressionCompiler @

    @setData data

  setData: (data, accessor) ->

  regulateKeypath: (keypath) ->
    return '' unless keypath?

    String(keypath)
    .replace(/^this\.?/, '')
    .replace(/\[(\d+)\]/g, '.$1')

  _buildKeypath: (paths...) -> _.compact(paths).join '.'


  #  Propagation
  #-----------------------------------------------
  _catchPropagatedEvents: (key) ->
    return if @_propagateHandlers[key]

    obj = @_data[key]

    return unless obj && obj.__observable

    general = (e, args...) =>
      e = e.clone()
      e.keypath = @_buildKeypath key, e.keypath
      e.propagated = true
      e.propagatedKeypath = e.keypath.split('.')[0...-1].join '.'
      @trigger e, args...

    detach = (e) =>
      @unset @_buildKeypath(key, e.keypath)

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


  #  Batch
  #-----------------------------------------------
  beginBatch: ->
    @_inBatch = true
    @_batchTracker ?= new Leaf.AffectedKeypathTracker @, 'set'

  endBatch: ->
    return unless @_inBatch

    tracker = @_batchTracker

    @_inBatch = false
    @_batchTracker = null

    keypaths = tracker.getAffectedKeypaths()

    _(keypaths).forEach (keypath) =>
      { obj, key } = @getTerminalObjectForKeypath keypath

      event = new Leaf.Event
        name: 'set'
        keypath: key

      if obj && obj.__observable
        obj.trigger event, obj._get(key)


  #  Getter
  #-----------------------------------------------
  getTerminalObjectForKeypath: (keypath, withoutDelegation) ->
    keypath = @regulateKeypath keypath

    path = keypath.split '.'
    len = path.length

    key = path.pop()
    obj = @

    if len > 1
      if withoutDelegation
        obj = obj._data[p] while obj && obj.__observable && (p = path.shift())
      else
        obj = obj._delegates[p]?.obj._data[p] ? obj._data[p] while obj && obj.__observable && (p = path.shift())
    else if !withoutDelegation
      obj = @_delegates[key]?.obj ? @

    { obj, key }

  _get: (key) ->
    return @ unless key?

    return @_delegates[key].obj._get key if @_delegates[key]

    e = new Leaf.Event
      name: 'get'
      keypath: key

    @trigger e

    val = @_data[key]

    if _.isFunction val
      tracker = new Leaf.AffectedKeypathTracker @, 'get' unless @_dependents[key]

      fn = val
      val = fn.call @
      fn._cachedValue = val

      if tracker
        dependents = tracker.getAffectedKeypaths()
        @_dependents[key] = dependents

        _(dependents).forEach (dependent) =>
          @on 'set', (e) =>
            return unless dependent == e.keypath

            event = new Leaf.Event
              name: 'update'
              keypath: key

            oldValue = fn._cachedValue
            newValue = fn.call @
            fn._cachedValue = newValue
            @trigger event, newValue, oldValue

    val

  get: (keypath) ->
    { obj, key } = @getTerminalObjectForKeypath keypath
    obj?._get key


  #  Setter
  #-----------------------------------------------
  _set: (key, val, options = {}) ->
    return unless key

    if (delegate = @_delegates[key])
      if options.withoutDelegation
        @undelegate key
      else
        return delegate.obj._set key, val, options

    options.notify ?= true

    @_accessor key

    oldValue = @_get key

    if _.isFunction @_data[key]
      @_data[key].call @, val
    else
      val = Leaf.Observable val
      @_uncatchPropagatedEvents key
      @_data[key] = val
      @_catchPropagatedEvents key

    if options.notify
      e = new Leaf.Event
        name: 'set'
        keypath: key

      @trigger e, val, oldValue

    val

  set: ->
    { keypath, val, options, pairs } = _.polymorphic
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


  #  Event
  #-----------------------------------------------
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


  #  Notify update
  #-----------------------------------------------
  _update: (key) ->
    e = new Leaf.Event
      name: 'update'
      keypath: key

    @trigger e

  update: (keypath) ->
    { obj, key } = @getTerminalObjectForKeypath keypath
    obj?._update key

  observe: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    keypath = @regulateKeypath keypath

    _callback = callback
    callback = _.bindContext callback, @, "observer:#{keypath}", (e) =>
      if !@_inBatch && (
        !keypath \
        || e.keypath == keypath \
        || "#{e.keypath}.".indexOf("#{keypath}.") == 0
      )
        _callback arguments...

    @on 'set', callback
    @on 'update', callback

  unobserve: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    keypath = @regulateKeypath keypath

    callback = _.bindContext callback, @, "observer:#{keypath}"

    @off 'set', callback
    @off 'update', callback


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

    @_accessor key
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
    @unsetCache @toLeafID()


