
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
    @_lastOperationDiff = null

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

  getDiff: ->
    return @_lastOperationDiff if @_lastOperationDiff

    diff = removed: [], added: [], moved: []

    if @_lastOperation.removed
      [from, to] = @_lastOperation.removed
      diff.removed = @_prev[from..to]

    if @_lastOperation.added
      [from, to] = @_lastOperation.added
      diff.added = @_map[from..to]

    removed = _.without diff.removed, diff.added...
    added = _.without diff.added, diff.removed...
    diff.removed = removed.map (v) => @_cache.get v
    diff.added = added.map (v) => @_cache.get v

    if @_lastOperation.changed
      prev = _.clone @_prev

      for i in [0...@_map.length] by 1
        continue if prev[i] == @_map[i]

        index = prev.indexOf @_map[i]

        continue if i > index

        diff.moved.push [i, index]
        tmp = prev[i]
        prev[i] = prev[index]
        prev[index] = tmp

    @_lastOperationDiff = diff

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
    @_parent.update? @_parent_key, @getDiff() if @_parent
    $(window).trigger @_getEventName(prop), [@getDiff()]

