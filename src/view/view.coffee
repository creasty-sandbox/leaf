
class Leaf.View extends Leaf.Object

  VAR_SELECTOR = /^\$(\w+)\s*(.+)/

  @_view: true

  __globallyUnique: true

  @setLeafClass()

  @parse: (buffer) ->
    psr = new Leaf.Template.Parser buffer
    tree = psr.getTree()

    (controller, scope) ->
      gen = new Leaf.Template.DOMGenerator tree, controller, scope
      gen.getDOM()

  initialize: (@viewData = {}) ->
    @inherit 'elements'
    @inherit 'events'

    @$body = $ 'body'

    @controller = @viewData.controller
    @scope = @viewData.scope

    @$view =
      if @viewData.tree
        @_elementFromParseTree @viewData.tree
      else
        @viewData.element ? $('<div/>')

    @$view.attr 'data-leaf-id', @_leafID

    @$view.data 'view', @

    p = @constructor

    while p && p._view
      @_registerMethodAsEventHandler p::
      p = p.__super__?.constructor

    @_setupElements()
    @setup()
    @_subscribeEvents()

  _registerMethodAsEventHandler: (o) ->
    _(o).forOwn (callback, method) =>
      unless (
        '_' == method[0] \           # private method
        || method == 'constructor' \ # class constructor
        || !_.isFunction(callback) \ # not function
        || Leaf.View::[method]       # method defined in Leaf.View
      )
        @$view.on method, => callback.apply @, arguments

  _elementFromParseTree: (tree) ->
    gen = new Leaf.Template.DOMGenerator _.cloneDeep(tree), @controller, @scope
    gen.getDOM()

  setup: ->

  _setupElements: ->
    pending = {}

    resolve = (name, selector, $find = @$view) =>
      if '@' == name[0]
        name = name[1..]
        $find = $ document

      $el = $find.find selector
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
          .replace /\$(\w+)/g, (_0, _1) => @elements[_1]

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
    { $el, name, handler } = _.polymorphic
      'o?sf': '$el name handler'
    , arguments

    return unless name || handler

    uid = "_binded_#{@_leafID}"
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
    { $el, name, handler } = _.polymorphic
      'o?sf?': '$el name handler'
    , arguments

    return unless name

    uid = "_binded_#{@_leafID}"
    handler = handler[uid] if handler && handler[uid]

    if $el
      $el.off name, handler
    else
      @getAppObserver().off name, handler

  send: ->
    # TODO

  render: ->

  detach: ->
    @$view.detach()

  destroy: ->
    @_unsubscribeEvents()
    @$view.detach()
    @$view = null

