
class ObservableArray extends ObservableBase

  constructor: (data, parent, parent_key) ->
    data.__proto__ = ObservableArray::
    data.init data, parent, parent_key
    return data

  _.extend @::, new Array

  init: (@_data, @_parent, @_parent_key) ->
    super()
    @_observed = []

    i = 0
    @_observed.push @_makeObservable(val, @, i++) for val in @

  cls = @

  push: (elements...) ->
    len = elements.length

    op =
      method: 'push'
      changed: len
      added: [@length, @length + len - 1]
      elements: elements

    Array::push.apply @, elements
    @_update null, op
    @

  unshift: (elements...) ->
    len = elements.length

    op =
      method: 'push'
      changed: len
      added: [@length, @length + len - 1]
      elements: elements

    Array::unshift.apply @, elements
    @_update null, op
    @

  pop: ->
    at = @length - 1

    op =
      method: 'pop'
      changed: 1
      removed: [at, at]

    res = Array::pop.apply @
    @_update null, op
    res

  shift: ->
    op =
      method: 'shift'
      changed: 1
      removed: [0, 0]

    res = Array::shift.apply @
    @_update null, op
    res

  splice: (args...) ->
    [index, size, elements...] = args

    len = elements.length
    diff = len - size

    op =
      method: 'splice'
      changed: Math.abs diff

    if size > 0
      op.removed = [index, index + size]

    if len > 0
      op.added = [index, index + len]
      op.elements = elements

    res = Array::splice.apply @, args
    @_update null, op
    res

  reverse: ->
    op =
      method: 'reverse'
      changed: @length
      added: [0, @length - 1]

    Array::reverse.apply @
    @_update null, op
    @

  sort: ->
    op =
      method: 'sort'
      changed: @length
      added: [0, @length - 1]

    Array::sort.apply @
    @_update null, op
    @

  removeAt: (index) ->
    @splice index, 1

  insertAt: (index, elements) ->
    @splice index, -1, elements...

  _update: (prop, op = {}) ->
    @_parent.update? @_parent_key, op if @_parent
    $(window).trigger @_getEventName(prop), [@get(prop), op]

