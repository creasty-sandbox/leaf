
class Leaf.ObservableBase extends Leaf.Class

  __observable: true

  _observableID = 0

  @mixin Leaf.Cacheable, Leaf.Accessible

  constructor: (data) ->
    @initMixin Leaf.Cacheable, Leaf.Accessible

    @_observableID = ++_observableID

    @_dependents = {}
    @_tracked = {}
    @_tracking = {}
    @_delegated = {}

    @_sync()

    @_initWithData data

  _initWithData: (data) ->

  _makeObservable: (o, parentObj, parentProp) ->
    if _.isArray o
      o = new Leaf.ObservableArray o
      o.setParent parentObj, parentProp
      o
    else if _.isPlainObject o
      o = new Leaf.ObservableObject o
      o.setParent parentObj, parentProp
      o
    else if o instanceof Leaf.ObservableBase
      o = o.cloneWithID()
      o.setParent parentObj, parentProp
      o
    else
      o

  setParent: (obj, prop) ->
    return unless obj

    @_hasParent = true
    @_parentObj = obj
    @_parentProp = prop

  unsetParent: ->
    @_hasParent = false
    @_parentObj = null
    @_parentProp = null

  clone: -> new @constructor @_data

  cloneWithID: ->
    o = new @constructor()
    o._observableID = @_observableID
    o._sync()
    o._initWithData @_data
    o

  _isTracking: (name) ->
    @_tracking[name] || @_hasParent && @_parentObj._isTracking(name)

  _beginTrack: (name) ->
    @_parentObj._beginTrack name if @_hasParent

    return if @_tracking[name]
    @_tracked[name] ?= []
    @_tracking[name] = true

  _createTrack: (name, val) ->
    @_parentObj._createTrack name, @_keypathFrom(@_parentProp, val) if @_hasParent

    return unless @_tracking[name]
    @_tracked[name].push val

  _endTrack: (name) ->
    @_parentObj._endTrack name if @_hasParent

    return unless @_tracking[name]

    tracked = @_tracked[name]
    @_tracked[name] = []
    @_tracking[name] = false

    keypaths = _.unique tracked
    stacks = {}

    # find terminal keypaths:
    # ['a.x', 'a.b.d', 'a.b.c.e']
    # in
    # ['a', 'a.b', 'a.x', 'a.b.c', 'a.b.d', 'a.b.c.e']
    #
    for keypath in keypaths
      stacks[keypath] = true

      props = keypath.split '.'

      # negate all the parents
      stacks[props.join('.')] = false while props.pop() && props[0]

    (path for path, flag of stacks when flag)

  beginBatch: ->
    @_inBatch = true
    @_beginTrack 'setter'

  endBatch: ->
    @_inBatch = false
    if (tracked = @_endTrack 'setter')
      _(tracked).forEach (prop) =>
        @_update prop

  _getComputed: (prop) ->
    val = @_data[prop]

    return val unless _.isFunction val

    @_beginTrack 'getter' unless @_dependents[prop]

    val = val.call @

    if (tracked = @_endTrack 'getter')
      @_dependents[prop] = tracked

      _(tracked).forEach (dependent) =>
        fn = (val, id, _prop) => @_update prop, true
        fn._dependentHandler = true
        @_observe dependent, fn

    val

  _keypathFrom: (path...) -> _.compact(path).join '.'

  _get: (prop) ->
    return @ unless prop?

    @_createTrack 'getter', prop

    @_getComputed prop

  get: (keypath) ->
    { obj, prop } = @getTerminalParent keypath

    obj?._get prop

  getTerminalParent: (keypath) ->
    return { obj: @ } unless keypath?

    keypath += ''
    keypath = keypath.replace /\[(\d+)\]/g, '.$1'
    path = keypath.split '.'
    len = path.length

    if len == 0
      { obj: @ }
    else if len == 1
      obj = @_data[keypath]
      if obj && obj.__observable
        { obj }
      else
        { obj: @, prop: keypath }
    else
      prop = path.pop()
      ref = @
      exist = obj: @, keypath: []

      while ref && (p = path.shift())
        exist.obj = ref if ref.__observable
        exist.keypath.push p
        ref = ref.get?(p) ? ref[p]

      exist.keypath.pop()

      { obj: ref, prop, exist }

  _set: (prop, val, options = {}) ->
    return unless prop

    options = _.defaults options,
      notify: true
      bubbling: false

    if options.overrideDelegate
      @_delegated[prop] = @_observableID

    if _.isFunction @_data[prop]
      @_data[prop].call @, val
    else
      obj = @_makeObservable val, @, prop
      @_data[prop] = obj

    @_createTrack 'setter', prop if options.notify
    @_createTrack 'setter' if options.bubbling

    unless @_inBatch
      @_update prop if options.notify
      @_update() if options.bubbling

    @_accessor prop

    val

  set: ->
    { keypath, val, options, pairs } = _.polymorphic
      'oo?':  'pairs options'
      's.o?': 'keypath val options'
    , arguments

    if pairs
      for k, v of pairs
        if _.isPlainObject v
          @get(k).set v, options
        else
          @set k, v, options

      return @

    { obj, prop } = @getTerminalParent keypath

    @_createTrack 'setter', keypath if options?.notify
    @_createTrack 'setter' if options?.bubbling

    obj._set prop, val, options

  _getUpdateEventName: (prop) ->
    id = @_delegated[prop] ? @_observableID
    "observer:update:#{id}"

  _sync: ->
    @_syncHandler = (e, id, prop, val) =>
      @_set prop, val, notify: false unless id == @_leafID
      null

    $(window).on @_getUpdateEventName(), @_syncHandler

  _update: (prop, dependentCall = false) ->
    $(window).trigger @_getUpdateEventName(prop), [@_leafID, prop, @_get(prop), dependentCall]
    @_parentObj._update @_parentProp if @_hasParent

  update: (keypath) ->
    { obj, prop } = @getTerminalParent keypath
    obj._update prop

  _observe: (prop, callback) ->
    fn = (e, id, prop, val, dependentCall) =>
      callback val, @toLeafID(), prop unless dependentCall && callback._dependentHandler

    callback._binded = fn
    $(window).on @_getUpdateEventName(prop), fn

  observe: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    { obj, prop } = @getTerminalParent keypath
    obj._observe prop, callback

  _unobserve: (prop, callback) ->
    $(window).off @_getUpdateEventName(prop), callback._binded ? callback

  unobserve: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    { obj, prop } = @getTerminalParent keypath
    obj._unobserve prop, callback

