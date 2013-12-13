
class Leaf.Template.DOM

  doc = document # copying global variable to local make js faster

  constructor: (@tree, @obj) ->
    @$parent = $ doc.createElement 'body'

  bind: (node) ->
    value = new Function node.vars..., "return (#{node.expr})"

    evaluate = =>
      args = node.vars.map (v) => @obj._get v
      value.apply null, args

    binder = (routine) =>
      @obj._beginTrack 'getter' unless value._dependents

      result = evaluate()

      if (dependents = @obj._endTrack 'getter')
        value._dependents = dependents
        @obj.observe d, (-> routine evaluate()) for d in dependents

      routine result

  createMarker: (name = '') ->
    if Leaf.develop
      $ doc.createComment 'leaf: ' + name
    else
      $ doc.createTextNode ''

  createElement: (node, $parent) ->
    $el = $ doc.createElement node.name
    $el.attr node.attrs

    for event, handler of node.actions
      $el.on event, (e) -> $el.trigger handler, [e]

    $el.appendTo $parent

  createTextNode: (node, $parent) ->
    $text = $ doc.createTextNode node.buffer
    $text.appendTo $parent

  createInterpolationNode: (node, $parent) ->
    binder = @bind node

    if node.escape
      el = doc.createTextNode ''
      $el = $el
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
        $el = @createElement node, $parent
        @createNode $el, node.contents
      when T_TAG_SELF
        @createElement node, $parent
      when T_TEXT
        @createTextNode node, $parent
      when T_INTERPOLATION
        @createInterpolationNode node, $parent

  getDOM: ->
    @createNode @$parent, @tree
    @$parent.children()

