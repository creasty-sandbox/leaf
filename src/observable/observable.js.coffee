
class Observable

  @SetOperationFailed: class extends Error

    constructor: (obj, key, value) ->
      @message = "Setting [#{key}] to [#{value}] on [#{obj}] failed"

  @makeObservable: (obj) ->
    for key, value of @::
      obj[key] = value

    obj._init()

  constructor: (obj) ->
    @_init()

    if obj?
      for key, value of obj
        @[key] = value

  set: (args...) ->
    batchStarted = @beginBatch()

    oldValue = if args.length == 1
      properties = args[0]
      for keypath, value of properties
        @_setOne(keypath, value)
    else
      @_setOne(args[0], args[1])

    if batchStarted
      @endBatch()

    oldValue

  get: (keypath) ->
    segments = keypath.split(".")

    if @_computedPropertyStack.length > 0
      dependentKeypath = @_computedPropertyStack[@_computedPropertyStack.length - 1]
      @_dependentKeypathsByKeypath[keypath] ?= {}
      @_dependentKeypathsByKeypath[keypath][dependentKeypath] = true

    @_followAndGetKeypathSegments(@, segments, keypath)

  invalidate: (keypath, oldValue, newValue) ->
    batchStarted = @beginBatch()

    if keypath of @_invalidationByKeypath
      @_invalidationByKeypath[keypath].newValue = newValue
    else
      @_invalidationByKeypath[keypath] =
        oldValue: oldValue
        newValue: newValue

    dependentKeypaths = @_dependentKeypathsByKeypath[keypath]
    if dependentKeypaths?
      for dependentKeypath of dependentKeypaths
        @invalidate(dependentKeypath, null, null)

    if batchStarted
      @endBatch()


  on: (keypath, observer) ->
    @_observersByKeypath[keypath] ?= []
    @_observersByKeypath[keypath].push observer

  off: (keypath, observer) ->
    observers = @_observersByKeypath[keypath]
    if observers?
      i = observers.indexOf observer
      if i != -1
        observers[i..i] = []

  beginBatch: ->
    if @_inBatch
      false
    else
      @_inBatch = true
      true

  endBatch: ->
    if @_inBatch
      @_inBatch = false

      for keypath, invalidation of @_invalidationByKeypath
        observers = @_observersByKeypath[keypath]
        if observers?
          for observer in observers
            observer(keypath, invalidation.oldValue, invalidation.newValue)

        delete @_invalidationByKeypath[keypath]
      true
    else
      false

  _init: ->
    @_observersByKeypath = {}
    @_dependentKeypathsByKeypath = {}
    @_computedPropertyStack = []
    @_inBatch = false
    @_invalidationByKeypath = {}

  _setOne: (keypath, value) ->
    segments = keypath.split(".")
    oldValue = @_followAndSetKeypathSegments(@, segments, value)
    @invalidate(keypath, oldValue, value)
    oldValue

  _followAndGetKeypathSegments: (parent, segments, keypath) ->
    if segments.length == 1
      if @_getObjectType(parent) == "observableLike"
        parent.get(segments[0])
      else
        @_invokeIfNecessary parent[segments[0]], keypath
    else
      if @_getObjectType(parent) == "observableLike"
        parent.get(segments.join("."))
      else
        firstSegment = segments.shift()
        if firstSegment of parent
          resolvedObject = @_invokeIfNecessary parent[firstSegment], keypath
          @_followAndGetKeypathSegments(resolvedObject, segments, keypath)
        else
          undefined

  _followAndSetKeypathSegments: (parent, segments, value) ->
    if segments.length == 1
      switch @_getObjectType(parent)
        when "observableLike"
          oldValue = parent.get segments[0]
          parent.set(segments[0], value)
          oldValue
        when "mapLike", "self"
          oldValue = parent[segments[0]]
          parent[segments[0]] = value
          oldValue
        else
          throw new Observable.SetOperationFailed(parent, segments[0], value)
    else
      if @_getObjectType(parent) == "observableLike"
        parent.set(segments.join("."), value)
      else
        firstSegment = segments.shift()
        resolvedObject = if firstSegment of parent
          @_invokeIfNecessary parent[firstSegment], null
        else
          parent[firstSegment] = {}

        @_followAndSetKeypathSegments(resolvedObject, segments, value)

  _invokeIfNecessary: (obj, keypath) ->
    if typeof obj == "function"
      try
        obj.apply(@)
      finally
        @_computedPropertyStack.pop()
    else
      obj

  _getObjectType: (obj) ->
    if obj?
      if obj == this
        "self"
      else if typeof obj.set == "function"
        "observableLike"
      else if Object.prototype.toString.call(obj) == "[object Array]"
        "array"
      else if obj instanceof Object
        "mapLike"
      else
        "other"
    else
      "nullLike"


###
class ObservableObject

  constructor: (@data) ->
    for own key, val of @data
      if $.isArray val
        @data[key] = new ObservableArray(val).getObserved()
      else if $.isObject val
        @data[key] = new ObservableObject(val).getObserved()

    @data.__proto__ = ObservableObject::
    @data.init()

  @:: = new Object

  getObserved: -> @data

  init: ->
    @initAccessors()
    @

  initAccessors: ->
    @accessor key for key in Object.keys(@)

  accessor: (key) ->
    data = @[key]

    Object.defineProperty @, key,
      enumerable: true
      configurable: true
      get: => data
      set: (val) =>
        data = val
        @change key

  change: (key) ->
    console.log key


class ObservableArray

  constructor: (@data) ->
    for i in [0...@data.length] by 1
      if $.isArray @data[i]
        @data[i] = new ObservableArray(@data[i]).getObserved()
      else if $.isObject @data[i]
        @data[i] = new ObservableObject(@data[i]).getObserved()

    @data.__proto__ = ObservableArray::

  @:: = new Array

  getObserved: -> @data

  ['push', 'concat', 'reverse', 'unshift']
  .forEach (method) =>
    @::[method] = (args...) ->
      Array::[method].apply @, args
      @change()
      @

  ['pop', 'shift', 'splice']
  .forEach (method) =>
    @::[method] = (args...) ->
      res = Array::[method].apply @, args
      @change()
      res

  removeAt: (index) ->
    @splice index, 1
    @

  insertAt: (index, element) ->
    @splice index, 0, element...
    @

  change: ->
    console.log 'array changed'


class Leaf.Observable

  constructor: (o) ->
    if $.isArray o
      new ObservableArray(o).getObserved()
    else
      new ObservableObject(o).getObserved()

###

