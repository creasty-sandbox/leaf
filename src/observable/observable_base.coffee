
class Leaf.ObservableBase extends Leaf.Class

  __observable: true

  @mixin Leaf.Cacheable, Leaf.Accessible

  constructor: (data) ->
    @initMixin Leaf.Cacheable, Leaf.Accessible

    @_dependents = {}
    @_tracked = {}
    @_tracking = {}
    @_delegates = {}

    @setData data

  setData: (data, accessor) ->

  _makeObservable: (o, parentObj, parentProp) ->
    if _.isArray o
      new Leaf.ObservableArray o
    else if _.isPlainObject o
      new Leaf.ObservableObject o
    else
      o

  setParent: (obj, prop) ->
    return unless obj
    @_parents[obj._leafID] = { obj, prop }

  unsetParent: (obj) ->
    @_parents[obj._leafID] = undefined

  _sendToParents: (method, args...) ->
    for id, p of @_parents when p
      p.obj[method].apply p, args

    null

  clone: ->
    o = new @constructor()
    o.delegate @
    o

  delegate: (o) ->

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

  _keypathFrom: (path...) -> _.compact(path).join '.'

  getDelegatedObjectForKeypath: (keypath) ->
    len = 0

    if keypath?
      keypath = String(keypath)
        .replace(/^this\.?/, '')
        .replace(/\[(\d+)\]/g, '.$1')

      path = keypath.split '.'
      len = path.length

    return { obj: @ } if len == 0

    id = @_leafID
    ref = @

    while ref && (p = path.shift())
      rid = ref._delegates[p]
      ref = @getCache rid
      return { obj: ref, key: p } if rid == id
      id = rid

    { obj: ref }

  _getComputedPropertyValue: (fn) ->
    @_beginTrack 'getter' unless @_dependents[key]

    val = fn.call @

    if (tracked = @_endTrack 'getter')
      @_dependents[key] = tracked

      _(tracked).forEach (dependent) =>
        fn = (val, id) => @_update prop, true
        fn._dependentHandler = true
        @_observe dependent, fn

    val

  _getValue: (key) ->
    return @ unless key?

    @_createTrack 'getter', key

    val = @_data[key]

    if _.isFunction val
      @_getComputedPropertyValue val
    else
      val

  get: (keypath) ->
    { obj, key } = @getDelegatedObjectForKeypath keypath
    obj?._getValue key

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
      @_update prop, options.dependent if options.notify
      @_update null, options.dependent if options.bubbling

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

  _unset: (prop, options) ->
    @_set prop, undefined, options

  unset: (keypath, options) ->
    { obj, prop } = @getTerminalParent keypath

    @_createTrack 'setter', keypath if options?.notify
    @_createTrack 'setter' if options?.bubbling

    obj._unset prop, options

  getEventName: (event, id = @_leafID) ->
    "observer:#{id}.#{event}"

  trigger: (event, args...) ->
    Leaf.sharedEvent.trigger @_getEventName(event), args...

  on: (event, handler) ->
    Leaf.sharedEvent.on @_getEventName(event), handler

  one: (event, handler) ->
    Leaf.sharedEvent.one @_getEventName(event), handler

  off: (event, handler) ->
    Leaf.sharedEvent.off @_getEventName(event), handler

  _update: (prop, dependentCall = false) ->
    $(window).trigger @_getEventName(prop), [@_leafID, prop, @_get(prop), dependentCall]
    @_parentObj._update @_parentProp if @_hasParent

  update: (keypath) ->
    { obj, prop } = @getTerminalParent keypath
    obj._update prop

  _observe: (prop, handler) ->
    event = 'valueDidChange'
    event = "#{event}.#{prop}" if prop?
    @on event, -> callback

  observe: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    { obj, prop } = @getDelegatedObjectForKeypath keypath
    obj.on 'valueDidChange', callback, @

  unobserve: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    { obj, prop } = @getTerminalParent keypath
    @on 'valueDidChange', callback, @
    obj._unobserve prop, callback

  detachFromParent: ->
    if @_hasParent
      if @_parentObj instanceof Leaf.ObservableObject
        @_parentObj.unset @_parentProp
      else
        @_parentObj.removeAt @_parentObj.indexOf(@)

  destroy: ->
    @detachFromParent()
    @_data = null
    @unsetCache @toLeafID()


