
class Leaf.ObservableArray extends Leaf.ObservableBase

  # toLeafIDs = (ary) -> Array::map.call ary, (v) -> if v?.__observable then v.toLeafID() else v

  setData: (data = []) ->
    @_data = []

    @_lastOperation = {}

    for i in [0...data.length] by 1
      val = @_makeObservable data[i], @
      @_data[i] = val
      @_accessor i

    @length = @_data.length
    @_archiveCurrentData()

  _archiveCurrentData: -> @_prev = _.clone @_data

  _recordOperation: (@_lastOperation = {}) ->
    @_lastPatch = null

  indexOf: (v) -> @_data.indexOf v

  _makeElementsObservable: (elements) ->
    elements.map (el) => @_makeObservable el, @

  push: (elements...) ->
    len = elements.length
    elements = @_makeElementsObservable elements

    @_recordOperation
      method: 'push'
      args: elements
      added: [@length, @length + len - 1]

    @_archiveCurrentData()
    @_data.push elements...
    @_update()
    @length

  unshift: (elements...) ->
    len = elements.length
    elements = @_makeElementsObservable elements

    @_recordOperation
      method: 'unshift'
      args: elements
      added: [0, len - 1]

    @_archiveCurrentData()
    @_data.unshift elements...
    @_update()
    @length

  pop: ->
    @_recordOperation
      method: 'pop'
      removed: [@length - 1, @length - 1]

    @_archiveCurrentData()
    res = @_data.pop()
    @_update()
    res

  shift: ->
    @_recordOperation
      method: 'shift'
      removed: [0, 0]

    @_archiveCurrentData()
    res = @_data.shift()
    @_update()
    res

  splice: (args...) ->
    [index, size, elements...] = args

    len = elements.length
    diff = len - size

    op =
      method: 'splice'
      args: args

    if size + 1 > 0
      op.removed = [index, index + size - 1]

    if len > 0
      op.added = [index, index + len - 1]

    @_recordOperation op
    @_archiveCurrentData()

    if len
      elements = @_makeElementsObservable elements
      res = @_data.splice index, size, elements...
    else
      res = @_data.splice index, size

    @_update()
    res

  reverse: ->
    @_recordOperation
      method: 'reverse'
      changed: true

    @_archiveCurrentData()
    @_data.reverse()
    @_update()
    @

  sort: (compareFunc) ->
    @_recordOperation
      method: 'sort'
      changed: true

    @_archiveCurrentData()
    @_data.sort compareFunc
    @_update()
    @

  removeAt: (index) ->
    @splice index, 1

  insertAt: (index, elements) ->
    @splice index, -1, elements...

  forEach: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    fn @get(i), i for i in [0...@length] by 1
    null

  map: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    (fn @get(i), i for i in [0...@length] by 1)

  every: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    return false for i in [0...@length] by 1 when !fn @get(i), i
    true

  some: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject
    return true for i in [0...@length] by 1 when fn @get(i), i
    false

  filter: (fn, thisObject) ->
    fn = fn.bind thisObject if thisObject

    result = new @constructor

    for i in [0...@length] by 1
      val = @get i
      result.push val if fn val, i

    result

  reduce: (fn, initialValue) ->
    result = initialValue ? @get 0
    result = fn result, @get(i), i, @ for i in [0...@length] by 1
    result

  reduceRight: (fn) ->
    i = @length
    result = @get i - 1
    result = fn result, @get(i - 1), i - 1, @ while --i
    result

  getSimplePatch: ->
    patch = []

    [rf, rt] = @_lastOperation.removed ? [0, -1]
    [af, at] = @_lastOperation.added ? [0, -1]

    for i in [rf..rt] by 1
      patch.push Leaf.ArrayDiffPatch.createPatch 'removeAt', rf, @_prev[i]

    for i in [af..at] by 1
      patch.push Leaf.ArrayDiffPatch.createPatch 'insertAt', i - rf, @_data[i]

    patch

  getPatch: ->
    return @_lastPatch if @_lastPatch

    @_lastPatch =
      if @_lastOperation.changed
        Leaf.ArrayDiffPatch.getPatch @_prev, @_data
      else
        @getSimplePatch()

  _set: (prop, val, options = {}) ->
    @_lastPatch = []
    @_lastOperation = method: 'set', args: [val, options]
    super prop, val, options

  _update: ->
    len = @_data.length

    if @length < len
      @_accessor i for i in [@length...len] by 1
    # else if @length > len
    #   @_removeAccessor i for i in [len...@length] by 1

    @length = len

    super()

  toArray: -> @_data

