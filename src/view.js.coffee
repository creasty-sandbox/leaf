
class Leaf.View extends Leaf.Object

  @_objectType = 'View'

  VAR_SELECTOR = /^\$(\w+)\s*(.+)/i

  constructor: (@controller) ->
    super()

    @elements ?= {}
    @events ?= {}

    @_setupElements()
    @setup()
    @_subscribeEvents()

  setup: ->

  _setupElements: ->
    pending = {}

    resolve = (name, selector, $find) =>
      $el =
        if $find
          $find.find selector
        else
          $ selector

      @setElement name, $el
      dfd = (pending[name] ?= $.Deferred())
      dfd.resolve $el

    _(@elements).forEach (selector, name) =>
      if (v = VAR_SELECTOR.exec selector)
        dfd = (pending[v[1]] ?= $.Deferred())
        dfd.done ($el) => resolve name, v[2], $el
      else
        selector = selector
          .replace(/^\\\$/, '$')
          .replace /\$(\w+)/g, (_0, _1) =>
            @elements[_1]

        resolve name, selector

  setElement: (name, val) -> @["$#{name}"] = val
  getElement: (name) -> @["$#{name}"]

  _subscribeEvents: ->
    _(@events).forEach (fn, def) =>
      [el, name...] = def.split ' '
      name = name.join ' '
      fn = @[fn] unless $.isFunction fn
      @subscribeEvent @getElement(el), name, fn

  subscribeEvent: ->
    { $el, name, handler } = Leaf.Utils.polymorphic
      'sf':  'name handler'
      'osf': '$el name handler'
    , arguments

    return unless name || handler

    uid = "_binded_#{@_id}"
    handler[uid] ?= handler.bind @
    handler = handler[uid]

    if $el
      $el.on name, handler
    else
      @getAppObserver().on name, handler

  _unsubscribeEvents: ->
    _(@events).forEach (fn, def) =>
      [el, name...] = def.split ' '
      name = name.join ' '
      @getElement(el).off name

  unsubscribeEvent: ->
    { $el, name, handler } = Leaf.Utils.polymorphic
      's':   'name'
      'sf':  'name handler'
      'os':  '$el name'
      'osf': '$el name handler'
    , arguments

    return unless name

    uid = "_binded_#{@_id}"
    handler = handler[uid] if handler && handler[uid]

    if $el
      $el.off name, handler
    else
      @getAppObserver().off name, handler

  send: ->
    # TODO

  destroy: ->
    @_unsubscribeEvents()


