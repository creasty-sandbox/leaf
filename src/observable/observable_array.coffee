
class Leaf.ObservableArray extends Leaf.ObservableBase

  toLeafIDs = (ary) -> Array::map.call ary, (v) -> if v?.__observable then v.toLeafID() else v

  constructor: (_data = []) ->
    super()
    @_data = []

    @_saveCurrentMap()
    @_lastOperation = {}

    for i in [0..._data.length] by 1
      val = @_makeObservable _data[i], @
      @_data[i] = val
      @_accessor i

    @length = @_data.length
    @_map = toLeafIDs @_data

  _saveCurrentMap: -> @_prev = _.clone @_map

  _recordOperation: (@_lastOperation = {}) ->
    @_lastPatch = null

  indexOf: (v) ->
    if v._leafObject
      @_map.indexOf v.toLeafID()
    else
      @_data.indexOf v

  push: (elements...) ->
    len = elements.length
    elements = elements.map (el) => @_makeObservable el, @

    @_recordOperation
      method: 'push'
      args: elements
      added: [@length, @length + len - 1]

    @_saveCurrentMap()
    @_data.push elements...
    @_map.push toLeafIDs(elements)...
    @_update()
    @length

  unshift: (elements...) ->
    len = elements.length
    elements = elements.map (el) => @_makeObservable el, @

    @_recordOperation
      method: 'unshift'
      args: elements
      added: [0, len - 1]

    @_saveCurrentMap()
    @_data.unshift elements...
    @_map.unshift toLeafIDs(elements)...
    @_update()
    @length

  pop: ->
    @_recordOperation
      method: 'pop'
      removed: [@length - 1, @length - 1]

    @_saveCurrentMap()
    res = @_data.pop()
    @_map.pop()
    @_update()
    res

  shift: ->
    @_recordOperation
      method: 'shift'
      removed: [0, 0]

    @_saveCurrentMap()
    res = @_data.shift()
    @_map.shift()
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
    @_saveCurrentMap()

    if len
      elements = elements.map (el) => @_makeObservable el, @
      res = @_data.splice index, size, elements...
      @_map.splice index, size, toLeafIDs(elements)...
    else
      res = @_data.splice index, size
      @_map.splice index, size

    @_update()
    res

  reverse: ->
    @_recordOperation
      method: 'reverse'
      changed: true

    @_saveCurrentMap()
    @_data.reverse()
    @_map.reverse()
    @_update()
    @

  sort: (compareFunc) ->
    @_recordOperation
      method: 'sort'
      changed: true

    @_saveCurrentMap()
    @_data.sort compareFunc
    @_map = toLeafIDs @_data
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
      patch.push Leaf.ArrayDiffPatch.createPatch 'removeAt', rf

    for i in [af..at] by 1
      patch.push Leaf.ArrayDiffPatch.createPatch 'insertAt', i - rf, @_map[i]

    patch.forEach (p) => p.element = @_cacheOrValue p.element
    patch

  _cacheOrValue: (o) ->
    if Leaf.Identifiable.isLeafID o
      @getCache o
    else
      o

  getPatch: ->
    return @_lastPatch if @_lastPatch

    if @_lastOperation.changed
      patch = Leaf.ArrayDiffPatch.getPatch @_prev, @_map
      patch.forEach (p) => p.element = @_cacheOrValue p.element
    else
      patch = @getSimplePatch()

    @_lastPatch = patch

  _set: (prop, val, options = {}) ->
    @_lastPatch = []
    @_lastOperation = method: 'set', args: [val, options]
    super prop, val, options

  _update: (prop) ->
    len = @_data.length

    if @length < len
      @_accessor i for i in [@length...len] by 1
    else if @length > len
      @_removeAccessor i for i in [len...@length] by 1

    @length = len

    super prop

  toArray: -> @_data

