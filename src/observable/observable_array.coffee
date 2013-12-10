
class Leaf.ObservableArray extends Leaf.ObservableBase

  toLeafIDs = (ary) -> Array::map.call ary, (v) -> if v._leafObject then v.toLeafID() else v

  init: ->
    super()
    @_saveCurrentMap()
    @_lastOperation = {}
    @length = @_data.length

    for i in [0...@_data.length] by 1
      val = @_makeObservable @_data[i], @
      @_data[i] = val
      @_accessor i

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
    @

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
    @

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
    elements = elements.map (el) => @_makeObservable el, @
    diff = len - size

    op =
      method: 'splice'
      args: args

    op.removed = [index, index + size - 1] if size + 1 > 0
    op.added = [index, index + len - 1] if len > 0

    @_recordOperation op

    @_saveCurrentMap()
    res = @_data.splice args...

    if len
      @_map.splice index, size, toLeafIDs(elements)...
    else
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

  getPatch: ->
    return @_lastPatch if @_lastPatch

    patch = []

    if @_lastOperation.changed
      patch = Leaf.ArrayDiffPatch.getPatch @_prev, @_map
    else
      [rf, rt] = @_lastOperation.removed ? [0, -1]
      [af, at] = @_lastOperation.added ? [0, -1]

      for i in [rf..rt] by 1
        patch.push Leaf.ArrayDiffPatch.createPatch 'removeAt', rf

      for i in [af..at] by 1
        patch.push Leaf.ArrayDiffPatch.createPatch 'insertAt', i - rf, [@_map[i]]

    patch.forEach (p) =>
      p.args[1][0] = @_cache.get p.args[1][0] if p.args[1]?

    @_lastPatch = patch

  cls = @
  [
    'forEach'
    'map'
    'every'
    'some'
    'filter'
    'reduce'
    'reduceRight'
  ].forEach (method) ->
    cls::[method] = -> @_data[method] arguments...

  _update: (prop, name) ->
    len = @_data.length

    if @length < len
      @_accessor i for i in [@length...len] by 1
    else if @length > len
      @_removeAccessor i for i in [len...@length] by 1

    @length = len

    if name == 'set'
      @_lastPatch = null
      @_lastOperation = null

    super prop, name

