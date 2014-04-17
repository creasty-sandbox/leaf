
#  Errors
#-----------------------------------------------
class UndefinedCustomTagError extends Leaf.Error


#  Generator
#-----------------------------------------------
class Leaf.Template.DOMGenerator

  doc = document # copying global variable to local make js faster

  { customTags } = Leaf.Template

  constructor: (@tree, @controller, @scope, @$parent) ->
    unless @tree
      throw new RequiredArgumentsError('tree')

    unless @controller
      throw new RequiredArgumentsError('controller')

    @scope ?= new Leaf.ObservableObject()

    @compiler = new Leaf.ExpressionCompiler @controller, @scope

    @$parent ?= $ doc.createElement 'body'
    @$parent.data 'leaf-scope', @scope

  bindAttributes: ($el, attrs) ->
    name = $el.get(0).nodeName.toLowerCase()

    _(attrs).forEach (val, key) =>
      if 'value' == key && 'option' != name
        user = false

        @compiler.bind val, (result) ->
          $el.val result unless user
          user = false
          null

        $el.data 'value-evaluator', => @compiler.eval val

        $el.on 'change keyup keydown keypress', =>
          user = true
          @controller.set val, $el.val()
      else if 'style' == key
        @compiler.bind val, (result) -> $el.css result # slow?
      else
        if 'option' == name
          $(doc).on 'viewDidRender', => # TODO: document is bad
            $select = $el.parent()

            if $select.length
              evaluate = $select.data 'value-evaluator'
              $el.prop 'selected', (evaluate() == @compiler.eval(val))

        @compiler.bind val, (result) -> $el.attr key, result

  bindLocales: ($el, attrs) ->
    @compiler.evalObject attrs, @scope
    $el.data 'leaf-scope', @scope

  registerActions: ($el, actions) ->
    _(actions).forEach (handler, event) ->
      $el.on event, (e) -> $el.trigger handler, [e]

    null

  createMarker: (node, closing) ->
    if node && Leaf.develop
      $ doc.createComment "<#{(if closing then '/' else '')}#{node.name}:#{node._nodeID}>"
    else
      $ doc.createTextNode ''

  createElement: (node, $parent) ->
    c = customTags.def[node.name]

    if node.customTag && !c
      throw new UndefinedCustomTagError "<#{node.name}>"

    c ?= {}

    scope = @scope.syncedClone()
    @compiler.evalObject node.localeBindings, scope

    if c.structure
      $begin = @createMarker node
      $end = @createMarker node, true

      $begin.appendTo $parent
      $end.appendTo $parent

      c.create?(
        node:       node
        $marker:    $begin
        $parent:    $parent
        controller: @controller
        scope:      scope
        compiler:   @compiler
      )

      return

    $el = $ doc.createElement node.name

    $el.attr node.attrs
    @bindAttributes $el, node.attrBindings
    @bindLocales $el, node.localeBindings
    @registerActions $el, node.actions

    if c.block
      $begin = @createMarker node
      $end = @createMarker node, true

      $begin.appendTo $parent
      $el.appendTo $parent
      $end.appendTo $parent

      c.create?(
        node:       node
        $marker:    $begin
        $parent:    $parent
        controller: @controller
        scope:      scope
        compiler:   @compiler
      )
    else
      $el.appendTo $parent
      n = new @constructor node.contents, @controller, scope, $el
      n.createNode n.$parent, n.tree

  createTextNode: (node, $parent) ->
    $text = $ doc.createTextNode _.unescape(node.buffer)
    $text.appendTo $parent

  createInterpolationNode: (node, $parent) ->
    $marker = @createMarker()
    $marker.appendTo $parent

    if node.escape
      el = doc.createTextNode ''
      $el = $ el
      $el.appendTo $parent

      @compiler.bind node.value, (result) ->
        el.nodeValue = result
    else
      $el = null

      @compiler.bind node.value, (result) ->
        if $el
          $el.remove()
          $el = null

        $el = $ $.parseHTML result
        $el.insertAfter $marker

  createNode: ($parent, node) ->
    if _.isArray node
      @createNode $parent, n for n in node
      return

    switch node.type
      when T_TAG_OPEN
        @createElement node, $parent
      when T_TAG_SELF
        @createElement node, $parent
      when T_TEXT
        @createTextNode node, $parent
      when T_INTERPOLATION
        @createInterpolationNode node, $parent

  getDOM: ->
    return @dom if @dom
    @createNode @$parent, @tree
    @dom = @$parent.contents()

