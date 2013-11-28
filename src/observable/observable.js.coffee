
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


