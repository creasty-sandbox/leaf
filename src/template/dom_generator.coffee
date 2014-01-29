
#  Errors
#-----------------------------------------------
class UndefinedCustomTagError extends Leaf.Error


#  Generator
#-----------------------------------------------
class Leaf.Template.DOMGenerator

  doc = document # copying global variable to local make js faster

  customTags = Leaf.Template.customTags

  constructor: ->

  init: (@tree, @obj) ->
    unless @tree
      throw new RequiredArgumentsError('tree')

    unless @obj
      throw new RequiredArgumentsError('obj')

    @binder = new Leaf.Template.Binder @obj
    @$parent = $ doc.createElement 'body'

  getBinder: (value) ->
    @binder.getBinder value, @obj

  bindAttributes: ($el, attrs) ->
    _(attrs).forEach (val, key) =>
      bind = @getBinder val

      if 'value' == key
        bind (result) -> $el.val result
        $el.on 'keyup keydown keypress', =>
          @obj.set val.expr, $el.val()
      else
        bind (result) -> $el.attr key, result


  bindLocales: ($el, attrs) ->
    binder = new Leaf.Template.Binder @obj
    bindingObj = binder.getBindingObject attrs

    $el.data 'leaf-locale', bindingObj

  registerActions: ($el, actions) ->
    for event, handler of actions
      $el.on event, (e) -> $el.trigger handler, [e]

  createMarker: (name = '') ->
    if Leaf.develop
      $ doc.createComment 'leaf: ' + name
    else
      $ doc.createTextNode ''

  createElement: (node, $parent) ->
    c = customTags.def[node.name]

    if node.customTag && !c
      throw new UndefinedCustomTagError "<#{node.name}>"

    c ?= {}

    if c.structure
      $marker = @createMarker node.name
      $marker.appendTo $parent
      c.create? node, $marker, $parent, @obj
      return

    $el = $ doc.createElement node.name

    $el.attr node.attrs
    @bindAttributes $el, node.attrBindings
    @bindLocales $el, node.localeBindings
    @registerActions $el, node.actions

    $el.appendTo $parent

    if c.block
      c.create? node, $el, $parent, @obj
    else
      @createNode $el, node.contents

  createTextNode: (node, $parent) ->
    $text = $ doc.createTextNode node.buffer
    $text.appendTo $parent

  createInterpolationNode: (node, $parent) ->
    bind = @getBinder node.value

    if node.escape
      el = doc.createTextNode ''
      $el = $ el
      $el.appendTo $parent

      bind (result) -> el.nodeValue = result
    else
      $marker = @createMarker 'interpolation'
      $marker.appendTo $parent
      $el = null

      bind (result) ->
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

