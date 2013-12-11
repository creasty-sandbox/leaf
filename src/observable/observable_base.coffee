
class Leaf.ObservableBase extends Leaf.Object

  @isObservable = true

  constructor: (@_data) ->
    @init()

  init: ->
    @_objectBaseInit()
    @_dependents = {}
    @_tracked = {}
    @_tracking = {}
    @_sub = {}

  _makeObservable: (o) ->
    if _.isArray o
      new Leaf.ObservableArray o
    else if _.isPlainObject o
      new Leaf.ObservableObject o
    else
      o

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
    val = @_data[prop]

    return val unless _.isFunction val

    @_beginTrack 'getter' unless @_dependents[prop]

    val = val.call @

    if (tracked = @_endTrack 'getter')
      @_dependents[prop] = tracked

      _(tracked).forEach (dependent) =>
        @_observe dependent, => @_update prop

    val

  _get: (prop, tracker = @, keypath) ->
    return @ unless prop?

    tracker._createTrack 'getter', keypath ? prop if tracker._tracking.getter

    @_getComputed prop

  get: (keypath) ->
    { obj, prop } = @getParent keypath
    obj._get prop, @, keypath

  getParent: (keypath) ->
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
      ref = @
      ref = ref.get?(p) ? ref[p] while ref && (p = path.shift())
      { obj: ref, prop }

  _set: (prop, val, options = {}) ->
    options = _.defaults { notify: true }, options

    if _.isFunction @_data[prop]
      @_data[prop].call @, val
    else
      @_data[prop] = val

    @_createTrack 'setter', prop if @_tracking.setter
    @_update prop if options.notify

    val

  set: ->
    { keypath, val, options, pairs } = Leaf.Utils.polymorphic
      '.': 'val'
      'oo?': 'pairs options'
      's.o?': 'keypath val options'
    , arguments

    if pairs
      for k, v of keypath
        if _.isPlainObject v
          @get(k).set v, options
        else
          @set k, v, options

      return @

    { obj, prop } = @getParent keypath
    obj._set prop, val, options

  _getEventName: (prop, o = @, eventName = 'update') ->
    name = ['observer']
    name.push eventName
    name.push o.toLeafID()
    name.push prop if prop
    name.join ':'

  _fire: (prop, eventName) ->
    $(window).trigger @_getEventName(prop, null, eventName), [@get(prop), eventName]

  _removeFromCollection: (prop) ->
    @_fire prop, 'removeFromCollection'

  removeFromCollection: (keypath) ->
    { obj, prop } = @getParent keypath
    obj._removeFromCollection prop

  _update: (prop, eventName = 'update') ->
    @_fire prop, eventName

  update: (keypath, eventName) ->
    { obj, prop } = @getParent keypath
    obj._update prop, eventName

  _observe: (prop, callback) ->
    fn = (e, args...) => callback args...
    callback._binded = fn
    $(window).on @_getEventName(prop), fn

  observe: ->
    { keypath, callback } = Leaf.Utils.polymorphic
      'f':  'callback'
      'sf': 'keypath callback'
    , arguments

    { obj, prop } = @getParent keypath
    obj._observe prop, callback

  _unobserve: (prop, callback) ->
    $(window).off @_getEventName(prop), callback._binded ? callback

  unobserve: (keypath, callback) ->
    { obj, prop } = @getParent keypath
    obj._unobserve prop, callback

