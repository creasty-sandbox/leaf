
Leaf.Template.customTags['if'] =
  reset: (node, parent) ->
    name = node.name

    if node.type == T_TAG_OPEN
      if name != 'elseif' && name != 'else'
        parent.context.if = null
    else if node.type == T_TAG_CLOSE
      if name != 'if' && name != 'elseif' && name != 'else'
        parent.context.if = null
    else
      parent.context.if = null
  parse: (node, parent) ->
    if node.type == T_TAG_OPEN
      parent.context.if = node

Leaf.Template.customTags['else'] =
  parse: (node, parent) ->
    if parent.context.if
      n = parent.context.if
      node.localeBindings.condition = "!(#{n.localeBindings.condition})"
      parent.context.if = null
    else if node.type == T_TAG_OPEN
      throw new Error 'Parse error'


class Leaf.Template.Parser

  constructor: (@buffer) ->
    return unless @buffer

    formatter = new Leaf.Formatter.HTML @buffer
    formatter.minify()
    @buffer = formatter.getHtml()

    @t = new Leaf.Template.Tokenizer @buffer

    @bindings = {}

    @root =
      name: '_root'
      contents: []
      scope: {}
      context: {}

    @parents = [@root]

  createNewScope: (node, parent) ->
    node.scope = _.merge _.clone(node.localeBindings), parent.scope

  parseKeypath: (path, parent) ->

  parseCustomTag: (node, parent) ->
    ctags = Leaf.Template.customTags
    ctags[node.name]?.parse node, parent

  resetCustomTags: (node, parent) ->
    ctags = Leaf.Template.customTags

    for name, ctag of ctags
      ctag.reset? node, parent
      ctag.other? node, parent unless name == node.name

  createTagNode: (token, parent) ->
    node = {}
    node.type = token.type
    node.contents = []
    node.context = {}
    node.name = token.name
    node.attrs = token.attrs
    node.attrBindings = token.attrBindings
    node.localeBindings = token.localeBindings
    node.actions = token.actions
    @createNewScope node, parent
    @parseCustomTag node, parent
    node

  createTextNode: (token) ->
    node = {}
    node.type = token.type
    node.buffer = token.buffer
    node

  createInterpolationNode: (token, parent) ->
    node = {}
    node.type = token.type
    node.val = token.textBinding.val
    node.escape = token.textBinding.escape
    node

  parseNode: (parents, token) ->
    p = parents[0]

    @resetCustomTags token, p

    switch token.type
      when T_TEXT
        node = @createTextNode token
        p.contents.push node
      when T_INTERPOLATION
        node = @createInterpolationNode token, p
        p.contents.push node
      when T_TAG_SELF
        node = @createTagNode token, p
        p.contents.push node
      when T_TAG_OPEN
        node = @createTagNode token, p
        p.contents.push node
        parents.unshift node
      when T_TAG_CLOSE
        if token.name == p.name
          parents.shift()
        else
          throw new Error 'Parse error'

  parseTree: (parents) ->
    token = @t.getToken()
    return if T_NONE == token.type
    @parseNode parents, token
    @parseTree parents

  getTree: ->
    return @parsedTree if @parsedTree
    @parseTree @parents, @states
    @parsedTree = @root.contents

  clone: ->
    tree = @getTree()
    _.cloneDeep tree

