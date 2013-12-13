
class Leaf.Template.DOM

  doc = document # copying global variable to local make js faster

  constructor: (@tree, @obj) ->
    @$parent = $ doc.createElement 'body'

  bind: ($el, node) ->
    value = new Function node.vars..., "return (#{node.expr})"
    getArgs = => node.vars (v) => @obj._get v
    binder = (routine) =>
      args = getArgs()
      @obj._beginTrack 'getter' unless value._dependents
      result = value.apply null, args

      if (dependents = @obj._endTrack 'getter')
        value._dependents = dependents
        @obj.observe d, binder for d in dependents

      routine result

  createElement: (node, $parent) ->
    $el = $ doc.createElement node.name
    $el.attr node.attrs

    for event, handler of node.actions
      $el.on event, (e) -> $el.trigger handler, [e]

    $el

  createTextNode: (node, parent) ->
    $ doc.createTextNode node.buffer

  createInterpolationNode: (node, parent) ->
    $el = $ doc.createTextNode ''
    binder = @bind $el, node
    binder (result) -> el.nodeValue result
    $el

  createNode: ($parent, node) ->
    if _.isArray node
      @createNode $parent, n for n in node
      return

    switch node.type
      when T_TAG_OPEN
        $el = @createElement node, $parent
        @createNode $el, node.contents
        $parent.append $el
      when T_TAG_SELF
        $el = @createElement node, $parent
        $parent.append $el
      when T_TEXT
        $text = @createTextNode node, $parent
        $parent.append $text
      when T_INTERPOLATION
        $interp = @createInterpolationNode node, $parent
        $parent.append $interp

  getDOM: ->
    @createNode @$parent, @tree
    @$parent.children()

