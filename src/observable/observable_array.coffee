
class Leaf.ObservableArray extends Leaf.ObservableBase

  toUUIDArray = (ary) -> Array::map.call ary, (v) -> v.toUUID?() ? v

  constructor: (data, parent, parent_key) ->
    data.__proto__ = Leaf.ObservableArray::
    data.init data, parent, parent_key
    return data

  _.extend @::, new Array

  init: (@_data, @_parent, @_parent_key) ->
    super()
    @_observed = []
    @_map = toUUIDArray @
    @_saveCurrentMap()
    @_lastOperation = {}

    @_observed.push @_makeObservable(val, @) for val in @

  _saveCurrentMap: -> @_prev = _.clone @_map

  _recordOperation: (@_lastOperation = {}) ->
    @_lastPatch = null

  push: (elements...) ->
    len = elements.length

    @_recordOperation
      method: 'push'
      args: elements
      added: [@length, @length + len - 1]

    @_saveCurrentMap()
    Array::push.apply @, elements
    @_map.push toUUIDArray(elements)...
    @_update()
    @

  unshift: (elements...) ->
    len = elements.length

    @_recordOperation
      method: 'unshift'
      args: elements
      added: [0, len - 1]

    @_saveCurrentMap()
    Array::unshift.apply @, elements
    @_map.unshift toUUIDArray(elements)...
    @_update()
    @

  pop: ->
    @_recordOperation
      method: 'pop'
      removed: [@length - 1, @length - 1]

    @_saveCurrentMap()
    res = Array::pop.apply @
    @_map.pop()
    @_update()
    res

  shift: ->
    @_recordOperation
      method: 'shift'
      removed: [0, 0]

    @_saveCurrentMap()
    res = Array::shift.apply @
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

    op.removed = [index, index + size] if size >= 0
    op.added = [index, index + len] if len > 0

    @_recordOperation op

    @_saveCurrentMap()
    res = Array::splice.apply @, args

    if len
      @_map.splice index, size, toUUIDArray(elements)...
    else
      @_map.splice index, size

    @_update()
    res

  reverse: ->
    @_recordOperation
      method: 'reverse'
      changed: true

    @_saveCurrentMap()
    Array::reverse.apply @
    @_map.reverse()
    @_update()
    @

  sort: (compareFunc) ->
    @_recordOperation
      method: 'sort'
      changed: true

    @_saveCurrentMap()
    Array::sort.call @, compareFunc
    @_map = toUUIDArray @
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
      [rf, rt] = @_lastOperation.removed ? [0, 0]
      [af, at] = @_lastOperation.added ? [0, 0]

      for i in [rf...rt] by 1
        patch.push Leaf.ArrayDiffPatch.createPatch 'removeAt', rf

      for i in [af...at] by 1
        patch.push Leaf.ArrayDiffPatch.createPatch 'insertAt', i - rf, [@_map[i]]

    patch.forEach (p) =>
      p.args[1] = @_cache.get p.args[1] if p.args[1]?

    @_lastPatch = patch

  _sync: ->

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
    cls::[method] = -> Array::[method].apply @, [arguments...]

  _update: (prop) ->
    @_sync()
    @_parent.update? @_parent_key, @ if @_parent
    $(window).trigger @_getEventName(prop), [@]

