
class Leaf.ObservableBase extends Leaf.Object

  constructor: (@_data, @_parent, @_parent_key) ->
    @init()

  init: ->
    @_objectBaseInit()
    @_dependents = {}
    @_tracked = {}
    @_tracking = {}

  _makeObservable: (o, parent, parent_key) ->
    if _.isArray o
      new Leaf.ObservableArray o, parent, parent_key
    else if _.isPlainObject o
      new Leaf.ObservableObject o, parent, parent_key
    else
      o?._parent = parent
      o?._parent_key = parent_key
      o

  _initAccessors: (accessors) ->
    return unless accessors
    @_accessor attr for attr in accessors

  _accessor: (attr) ->
    Object.defineProperty @, attr,
      enumerable: true
      configurable: true
      get: => @get attr
      set: (val) => @set attr, val

  _removeAccessor: (attr) ->
    Object.defineProperty @, attr,
      enumerable: false
      configurable: true
      value: undefined

  _beginTrack: (name) ->
    @_tracked[name] ?= []
    @_tracking[name] = true

  _createTrack: (name, val) -> @_tracked[name].push val

  _endTrack: (name) ->
    return unless @_tracking[name]

    tracked = @_tracked[name]
    @_tracked[name] = []
    @_tracking[name] = false
    tracked

  beginBatch: ->
    @_beginTrack 'setter'

  endBatch: ->
    if (tracked = @_endTrack 'setter')
      _(tracked).unique().forEach (prop) =>
        @_update prop

  _getComputed: (prop) ->
    fn = @_observed[prop]

    @_beginTrack 'getter' unless @_dependents[prop]

    val = fn.call @

    if (tracked = @_endTrack 'getter')
      @_dependents[prop] = tracked

      _(tracked).forEach (dependent) =>
        @_observe dependent, => @_update prop

    val

  _get: (prop, tracker = @, keypath) ->
    return @ unless prop?

    tracker._createTrack 'getter', keypath ? prop if tracker._tracking.getter

    val = @_observed[prop]

    if _.isFunction val
      @_getComputed prop
    else
      val

  get: (keypath) ->
    { obj, prop } = @getProperty keypath
    obj._get prop, @, keypath

  getProperty: (keypath) ->
    return { obj: @ } unless keypath?

    keypath += ''
    path = keypath.split '.'
    len = path.length

    if len == 0
      { obj: @ }
    else if len == 1
      { obj: @, prop: keypath }
    else
      prop = path.pop()
      obj = @
      ref = @_observed

      while ref && (p = path.shift())
        p = @_intOrKey p
        obj = ref if ref._observed
        ref = ref.get?(p) ? ref[p]

      { obj, prop }

  _set: (prop, val) ->
    prop = @_intOrKey prop

    if _.isFunction @_observed[prop]
      @_observed[prop].call @, val
    else
      @_observed[prop] = val

    if @_tracking.setter
      @_createTrack 'setter', prop
    else
      @_update prop

    val

  set: (keypath, val) ->
    if _.isPlainObject keypath
      for k, v of keypath
        if _.isPlainObject v
          @get(k).set v
        else
          @set k, v

      return @

    { obj, prop } = @getProperty keypath
    obj._set prop, val

  _getEventName: (prop) ->
    name = "observable:#{@toUUID()}"
    name += ':' + prop if prop
    name

  _destroy: (prop) ->
    if @_parent && @_parent.removeAt
      index = @_parent.indexOf @
      @_parent.removeAt index

  destroy: (keypath) ->
    { obj, prop } = @getProperty keypath
    obj._destroy prop

  _update: (prop, data) ->
    @_parent.update? @_parent_key, data if @_parent
    $(window).trigger @_getEventName(prop), [data ? @get(prop)]

  update: (keypath, data) ->
    { obj, prop } = @getProperty keypath
    obj._update prop, data

  _observe: (prop, callback) ->
    fn = (e, args...) => callback args...
    callback._binded = fn
    $(window).on @_getEventName(prop), fn

  observe: ->
    { keypath, callback } = Leaf.Utils.polymorphic
      'f':  'callback'
      'sf': 'keypath callback'
    , arguments

    { obj, prop } = @getProperty keypath
    obj._observe prop, callback

  _unobserve: (prop, callback) ->
    $(window).off @_getEventName(prop), callback._binded ? callback

  unobserve: (keypath, callback) ->
    { obj, prop } = @getProperty keypath
    obj._unobserve prop, callback

