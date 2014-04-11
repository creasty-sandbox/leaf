
class Leaf.ObservableArray extends Leaf.ObservableBase

  setData: (data = [], accessor = true) ->
    @_data = []

    @_lastOperation = {}
    @_detachHandlers = {}

    for i in [0...data.length] by 1
      val = Leaf.Observable data[i]
      @_data[i] = val
      @_catchDetachEventOn val
      @_accessor i if accessor

    @defineProperty 'length',
      enumerable: false
      configurable: true
      get: -> @_data.length
      set: (val) -> val

    @_archiveCurrentData()

  _archiveCurrentData: -> @_prev = _.clone @_data

  _recordOperation: (@_lastOperation = {}) ->

  _makeElementsObservable: (elements) ->
    elements.map (el) -> Leaf.Observable el


  #  Detach
  #-----------------------------------------------
  _catchDetachEventOn: (obj) ->
    return unless obj instanceof Leaf.ObservableObject

    id = obj._leafID

    return if @_detachHandlers[id]

    handler = (e, element) =>
      idx = @indexOf element
      @removeAt idx if ~idx

    @_detachHandlers[id] = handler
    obj.on 'detach', handler

  _uncatchDetachEventOn: (obj) ->
    return unless obj instanceof Leaf.ObservableObject

    id = obj._leafID
    return unless (handler = @_detachHandlers[id])

    @_detachHandlers[id] = null
    obj.off 'detach', handler


  #  Mutator methods
  #-----------------------------------------------
  push: (elements...) ->
    len = @_data.length

    elen = elements.length
    elements = @_makeElementsObservable elements
    @_catchDetachEventOn element for element in elements

    @_recordOperation
      locally: true
      method: 'push'
      added: [len, len + elen - 1]

    @_archiveCurrentData()
    @_data.push elements...
    @_update()
    @_data.length

  unshift: (elements...) ->
    len = elements.length
    elements = @_makeElementsObservable elements
    @_catchDetachEventOn element for element in elements

    @_recordOperation
      locally: true
      method: 'unshift'
      added: [0, len - 1]

    @_archiveCurrentData()
    @_data.unshift elements...
    @_update()
    @_data.length

  pop: ->
    len = @_data.length

    @_recordOperation
      locally: true
      method: 'pop'
      removed: [len - 1, len - 1]

    @_archiveCurrentData()
    res = @_data.pop()
    @_uncatchDetachEventOn res
    @_update()
    res

  shift: ->
    @_recordOperation
      locally: true
      method: 'shift'
      removed: [0, 0]

    @_archiveCurrentData()
    res = @_data.shift()
    @_uncatchDetachEventOn res
    @_update()
    res

  sort: (compareFunc) ->
    @_recordOperation
      locally: false
      method: 'sort'
      args: [compareFunc]

    @_archiveCurrentData()
    @_data.sort compareFunc
    @_update()
    @

  splice: (args...) ->
    [index, size, elements...] = args

    len = elements.length
    diff = len - size

    op =
      locally: false
      method: 'splice'

    if size + 1 > 0
      op.removed = [index, index + size - 1]

    if len > 0
      op.added = [index, index + len - 1]

    @_recordOperation op
    @_archiveCurrentData()

    if len
      elements = @_makeElementsObservable elements
      res = @_data.splice index, size, elements...
      @_catchDetachEventOn element for element in elements
    else
      [rf, rt] = op.removed
      @_uncatchDetachEventOn @_data[i] for i in [rf..rt] by 1
      res = @_data.splice index, size

    @_update()
    res

  reverse: ->
    @_recordOperation
      locally: false
      method: 'reverse'

    @_archiveCurrentData()
    @_data.reverse()
    @_update()
    @

  swap: (i, j) ->
    @_recordOperation
      locally: true
      method: 'swap'
      args: [i, j]

    @_archiveCurrentData()

    tmp = @_data[i]
    @_data[i] = @_data[j]
    @_data[j] = tmp

    @_update()
    @

  removeAt: (index) ->
    @splice index, 1

  insertAt: (index, elements) ->
    @splice index, -1, elements...


  #  Setter
  #-----------------------------------------------
  _set: (index, val, options = {}) ->
    return unless index?

    index >>>= 0

    @_recordOperation
      locally: true
      method: 'set'
      removed: [index, index]
      added: [index, index]

    options.notify ?= true

    @_accessor index

    oldValue = @_data[index]
    val = Leaf.Observable val

    @_uncatchPropagatedEvents oldValue
    @_data[index] = val
    @_catchPropagatedEvents val

    if options.notify
      e = new Leaf.Event
        name: 'set'
        keypath: index

      @trigger e, val, oldValue

    val


  #  Accessor methods
  #-----------------------------------------------
  indexOf: (element, offset) -> @_data.indexOf element, offset
  lastIndexOf: (element, offset) -> @_data.lastIndexOf element, offset


  #  Iterator methods
  #-----------------------------------------------
  forEach: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    fn @get(i), i for i in [0...@_data.length] by 1
    null

  map: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    (fn @get(i), i for i in [0...@_data.length] by 1)

  every: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    return false for i in [0...@_data.length] by 1 when !fn @get(i), i
    true

  some: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    return true for i in [0...@_data.length] by 1 when fn @get(i), i
    false

  filter: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject

    result = new @constructor

    for i in [0...@_data.length] by 1
      val = @get i
      result.push val if fn val, i

    result

  reduce: (fn, initialValue) ->
    result = initialValue ? @get 0
    result = fn result, @get(i), i, @ for i in [0...@_data.length] by 1
    result

  reduceRight: (fn) ->
    i = @_data.length
    result = @get i - 1
    result = fn result, @get(i - 1), i - 1, @ while --i
    result


  #  Mutation notify
  #-----------------------------------------------
  _update: ->
    len = @_data.length
    plen = @_prev.length

    if plen < len
      @_accessor i for i in [plen...len] by 1

    super()


  #  Sync
  #-----------------------------------------------
  sync: (handlers) ->
    ###
    # handlers =
    #   insertAt: (i, element) =>
    #     obj.insertAt i, element
    #   removeAt: (i) =>
    #     obj.removeAt i
    #   swap: (i, j) =>
    #     obj.swap i, j
    ###

    op = @_lastOperation

    if op.locally
      if op.removed
        [rf, rt] = op.removed

        handlers.insertAt rf, @_data[i] for i in [rf..rt] by 1

      if op.added
        [af, at] = op.added

        handlers.removeAt i - rf for i in [af..at] by 1

      if 'swap' == op.method
        handlers.swap op.args...
    else
      prev = [@_prev...]
      len = prev.length

      for i in [0...len] by 1
        unless prev[i] == @_data[i]
          j = @_data.indexOf prev[i]

          tmp = prev[i]
          prev[i] = prev[j]
          prev[j] = tmp

          handlers.swap i, j

    @


  #  Utils
  #-----------------------------------------------
  toArray: -> [@_data...]

