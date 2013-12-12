
class Leaf.Template.DOM

  doc = document # copying global variable to local make js faster

  constructor: (@tree, @obj) ->
    @$parent = $ doc.createElement 'body'

  createElement: (node, $parent) ->
    $el = $ doc.createElement node.name
    $el.attr node.attrs
    $el

  createTextNode: (node, parent) ->
    $ doc.createTextNode node.buffer

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
        $interp = @createTextNode node, $parent
        $parent.append $interp

  getDOM: ->
    @createNode @$parent, @tree
    @$parent.children()

