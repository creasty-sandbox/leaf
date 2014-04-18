
#  HTML5 attributes
#-----------------------------------------------
ATTR_REGEXP = ///
  \s+       # need spaces seperater
  (\$|\@|)  # $ or @ or nothing
  ([\w\-]+) # property name
  (?: # value?
    =
    (?:
      (?:\"([^\"]+?)\")   # double quotes
      | (?:\'([^\']+?)\') # single quotes
    )
  )?
///g

HTML5_SELF_CLOSING_TAGS = /^(img|input|hr|br|wbr|outlet|render|component:[\w\-]+)$/
HTML5_ATTR_BOOLEANS     = /^(disabled|selected|checked|contenteditable)$/


#  Errors
#-----------------------------------------------
class UnbalancedTagParseError extends Leaf.Error


#  Parser
#-----------------------------------------------
class Leaf.Template.Parser

  _nodeID = 0

  customTags = Leaf.Template.customTags

  constructor: (@buffer) ->
    unless @buffer?
      throw new RequiredArgumentsError('buffer')

    preformatter = new Leaf.Template.Preformatter @buffer
    @buffer = preformatter.getResult()

    @tokenizer = new Leaf.Template.Tokenizer @buffer

    @bindings = {}

    @root =
      _nodeID: ++_nodeID
      name: '_root'
      contents: []
      context: {}

    @parents = [@root]

    @parsedTree = null

  customTagOpen: (node, parent) ->
    c = customTags.def[node.name]
    return unless c && c.open
    c.open node, parent

  customTagClose: (node, parent) ->
    c = customTags.def[node.name]
    return unless c && c.close
    c.close node, parent

  customTagReset: (node, parent) ->
    for r in customTags.resets
      customTags.def[r].reset node, parent

  customTagOpenOther: (node, parent) ->
    for r in customTags.openOthers when r != node.name
      customTags.def[r].openOther node, parent

  customTagCloseOther: (node, parent) ->
    for r in customTags.closeOthers when r != node.name
      customTags.def[r].closeOther node, parent

  parseTagAttrs: (node, attrs) ->
    node.attrs = {}
    node.attrBindings = {}
    node.localeBindings = {}
    node.actions = {}

    return unless attrs

    attrs = " #{attrs} " # makes thing easier

    ATTR_REGEXP.lastIndex = 0

    while (m = ATTR_REGEXP.exec attrs)
      binding = m[1]
      key = m[2]
      val = m[3] || m[4]

      if '$' == binding
        node.localeBindings[key] = val
      else if '@' == binding
        node.actions[key] = val
      else if ~val.indexOf '{{'
        node.attrBindings[key] = val
      else
        node.attrs[key] = val

    ATTR_REGEXP.lastIndex = 0

  createTagNode: (token, parent) ->
    node = {}
    node._nodeID = ++_nodeID
    node.type = token.type
    node.contents = []
    node.context = {}
    node.name = token.name

    node.customTag = !!customTags.def[node.name]

    if token.closing
      node.closing = true
    else
      node.selfClosing = token.selfClosing
      node.selfClosing ||= !!token.name.match HTML5_SELF_CLOSING_TAGS
      node.selfClosing ||= !!customTags.def[token.name]?.selfClosing

    @parseTagAttrs node, token.attrPart

    node

  createTextNode: (token) ->
    node = {}
    node.type = token.type
    node.buffer = token.buffer
    node.empty = !!node.buffer.match /^\s*$/
    node

  createInterpolationNode: (token, parent) ->
    node = {}
    node.type = token.type
    node.escape = token.textBinding.escape
    expr = _.unescape token.textBinding.val
    node.value = expr
    node

  parseNode: (parents, token) ->
    p = parents[0]

    switch token.type
      when T_TEXT
        node = @createTextNode token
        @customTagReset token, p unless node.empty
        p.contents.push node
      when T_INTERPOLATION
        @customTagReset token, p
        node = @createInterpolationNode token, p
        p.contents.push node
      when T_TAG
        if token.closing
          if token.name == p.name
            _p = parents.shift()
            p = parents[0]
            @customTagCloseOther _p, p
            @customTagClose _p, p
          else
            throw new UnbalancedTagParseError "expect </#{p.name}> instead of </#{token.name}>"
        else
          node = @createTagNode token, p
          @customTagOpenOther token, p
          @customTagOpen node, p
          p.contents.push node
          parents.unshift node unless node.selfClosing

  parseTree: (parents) ->
    token = @tokenizer.getToken()
    return if T_NONE == token.type
    @parseNode parents, token
    @parseTree parents

  getTree: ->
    return @parsedTree if @parsedTree
    @parseTree @parents
    @parsedTree = @root.contents

  clone: ->
    tree = @getTree()
    _.cloneDeep tree


