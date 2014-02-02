
class Leaf.View extends Leaf.Object

  VAR_SELECTOR = /^\$(\w+)\s*(.+)/

  @setLeafClass()

  @parse: (buffer) ->
    psr = new Leaf.Template.Parser()
    psr.init buffer
    tree = psr.getTree()

    (obj) ->
      gen = new Leaf.Template.DOMGenerator()
      gen.init tree, obj
      gen.getDOM()

  initialize: (elementOrTree, data = {}) ->
    @inherit 'elements'
    @inherit 'events'

    @$body = $ 'body'

    fromTree = _.isPlainObject(elementOrTree) && elementOrTree.tree

    @$view =
      if fromTree
        @_elementFromParseTree elementOrTree
      else
        elementOrTree ? $('<div/>')

    @$view.data 'view', @
    @$view.attr "data-leaf-id", @_leafID

    if data.model
      @model = data.model

      if fromTree
        @setCache elementOrTree.id, @

    if data.collection
      @collection = data.collection

    @locale = @$view.data 'leaf-locale'

    @_setupElements()
    @setup()
    @_subscribeEvents()

  _elementFromParseTree: ({ tree, obj }) ->
    gen = new Leaf.Template.DOMGenerator()
    gen.init _.cloneDeep(tree), obj
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

  render: ($marker) ->
    @$view.insertBefore $marker

  detach: ->
    @$view.detach()

  destroy: ->
    @_unsubscribeEvents()
    @$view.detach()
    @$view = null

