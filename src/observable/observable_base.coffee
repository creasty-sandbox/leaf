
class Leaf.ObservableBase extends Leaf.Class

  __observable: true

  @mixin Leaf.Cacheable, Leaf.Accessible

  constructor: ->
    @initMixin Leaf.Cacheable, Leaf.Accessible

    @_dependents = {}
    @_tracked = {}
    @_tracking = {}
    @_sub = {}
    @_mergedObservable = _data: {}

  _makeObservable: (o, parentObj, parentProp) ->
    if _.isArray o
      o = new Leaf.ObservableArray o
      o.setParent parentObj, parentProp
      o
    else if _.isPlainObject o
      o = new Leaf.ObservableObject o
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

  cloneWithSameID: ->
    clone = new @constructor()
    clone._leafID = @_leafID
    @constructor.call clone, @_data
    clone

  mergeWith: (o) -> @_mergedObservable = o

  _beginTrack: (name) ->
    return if @_tracking[name]
    @_tracked[name] ?= []
    @_tracking[name] = true

  _createTrack: (name, val) ->
    @_parentObj._createTrack name, @_keypathFrom(@_parentProp, val) if @_hasParent

    return unless @_tracking[name]
    @_tracked[name].push val

  _endTrack: (name) ->
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
    @_beginTrack 'setter'

  endBatch: ->
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
        @_observe dependent, => @_update prop

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

    if _.isFunction @_data[prop]
      @_data[prop].call @, val
    else
      obj = @_makeObservable val, @, prop
      @_data[prop] = obj
    if @_tracking.setter
      @_createTrack 'setter', prop if options.notify
      @_createTrack 'setter' if options.bubbling
    else
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

    if @_tracking.setter
      @_createTrack 'setter', keypath if options?.notify
      @_createTrack 'setter' if options?.bubbling
    else
      obj._set prop, val, options, @

  _getEventName: (prop, o = @, eventName = 'update') ->
    name = ['observer']
    name.push eventName
    name.push o.toLeafID()
    name.push prop if prop
    name.join ':'

  _fire: (prop, eventName) ->
    $(window).trigger @_getEventName(prop, null, eventName), [@get(prop)]

  _update: (prop) ->
    @_fire prop, 'update'
    @_parentObj._update @_parentProp if @_hasParent

  update: (keypath) ->
    { obj, prop } = @getTerminalParent keypath
    obj._update prop

  _observe: (prop, callback) ->
    fn = (e, args...) => callback args...
    callback._binded = fn
    $(window).on @_getEventName(prop), fn

  observe: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    { obj, prop } = @getTerminalParent keypath
    obj._observe prop, callback

  _unobserve: (prop, callback) ->
    $(window).off @_getEventName(prop), callback._binded ? callback

  unobserve: ->
    { keypath, callback } = _.polymorphic
      's?f': 'keypath callback'
    , arguments

    { obj, prop } = @getTerminalParent keypath
    obj._unobserve prop, callback

