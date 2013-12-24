
class Leaf.Template.Binder

  @getFunction: (expr, vars) ->
    new Function vars..., "return (#{expr})"

  @getEvaluator: (fn, vars, obj) ->
    evaluate = ->
      args = vars.map (v) => obj._get v
      try fn.apply null, args

  @getBinder: ({ expr, vars }, obj) ->
    value = @getFunction expr, vars

    evaluate = @getEvaluator value, vars, obj

    binder = (routine) =>
      obj._beginTrack 'getter' unless value._dependents

      result = evaluate()

      if (dependents = obj._endTrack 'getter')
        value._dependents = dependents
        obj.observe d, (-> routine evaluate()) for d in dependents

      routine result


class Leaf.Template.DOMGenerator

  doc = document # copying global variable to local make js faster

  customTags = Leaf.Template.customTags

  constructor: ->

  init: (@tree, @obj, @scope = {}) ->
    unless @tree
      throw new RequiredArgumentsError('tree')

    unless @obj
      throw new RequiredArgumentsError('obj')

    @$parent = $ doc.createElement 'body'

  bind: (value) ->
    Leaf.Template.Binder.getBinder value, @obj

  bindAttributes: ($el, attrs) ->
    _(attrs).forEach (val, key) =>
      binder = @bind val
      binder (result) -> $el.attr key, result

  bindLocales: ($el, attrs) ->
    # TODO
    $el.data 'leaf-locale', attrs

  registerActions: ($el, actions) ->
    for event, handler of actions
      $el.on event, (e) -> $el.trigger handler, [e]

  createMarker: (name = '') ->
    if Leaf.develop
      $ doc.createComment 'leaf: ' + name
    else
      $ doc.createTextNode ''

  createElement: (node, $parent) ->
    c = customTags.def[node.name] ? {}

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
    binder = @bind node.value

    if node.escape
      el = doc.createTextNode ''
      $el = $ el
      $el.appendTo $parent

      binder (result) -> el.nodeValue = result
    else
      $marker = @createMarker 'interpolation'
      $marker.appendTo $parent
      $el = null

      binder (result) ->
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

