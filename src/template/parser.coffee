
#  Attribute patterns
#-----------------------------------------------
ATTR_REGEXP = ///
  \s+       # need spaces seperater
  (\$|\@|)  # $ or @ or nothing
  ([\w\-]+) # property name
  (?:       # has value?
    =
    (?:
      (?:\"([^\"]+?)\")   # double quotes
      | (?:\'([^\']+?)\') # single quotes
    )
  )?
///g

ATTR_PRESERVED =
  '*': ///
    ^(
      accesskey | class | contenteditable | contextmenu | dir | draggable
      | dropzone | hidden | id | lang | spellcheck | style | tabindex | title
      | on(
        abort | blur | canplay(through)? | change | click
        | contextmenu | cuechange | dblclick | drag(end|enter|leave|over|start)?
        | drop | durationchange | emptied | ended | error | focus
        | form(change|input)? | input | invalid | key(down|press|up)?
        | load(start)? | loaded(meta)?data | progress
        | mouse(down|move|out|over|up|wheel) | pause | play(ing)?
        | ratechange | readystatechange | reset | scroll | seeked(ing)?
        | select | show | stalled | submit | suspend | timeupdate | volumechange | waiting
      )
    )$
  ///
  'html': /^(manifest)$/
  'a': /^(href|target|rel|media|hreflang|type)$/
  'audio': /^(src|crossorigin|preload|autoplay|mediagroup|loop|muted|controls)$/
  'blockquote': /^(cite)$/
  'body': ///
    ^on(
      afterprint | before(print|unload) | blur | error | focus | hashchange
      | (un)?load | message | (off|on)?line | page(hide|show) | popstate
      | resize | scroll | storage
    )$
  ///
  'button': /^(autofocus|disabled|form(action|enctype|method|novalidate|target)?|name|type|value)$/
  'canvas': /^(width|height)$/
  'colgroup': /^(span)$/
  'col': /^(span)$/
  'command': /^(type|label|icon|disabled|checked|radiogroup|command)$/
  'del': /^(cite|datetime)$/
  'details': /^(open)$/
  'dialog': /^(open)$/
  'embed': /^(src|type|width|height)$/
  'fieldset': /^(disabled|form|name)$/
  'form': /^(accept-charset|action|autocomplete|enctype|method|name|novalidate|target)$/
  'iframe': /^(src|srcdoc|name|sandbox|seamless|width|height)$/
  'img': /^(alt|src|usemap|ismap|width|height)$/
  'input': ///
    ^(
      accept | alt | autocomplete | autofocus | checked | disabled
      | form(action|enctype|method|novalidate|target)?  | height | list | max(length)?
      | min | multiple | name | pattern | placeholder | readonly | required | size
      | src | step | type | value | width
    )$
  ///
  'ins': /^(cite|datetime)$/
  'keygen': /^(autofocus|challenge|disabled|form|keytype|name)$/
  'label': /^(form|for)$/
  'li': /^(value)$/
  'menu': /^(type|label)$/
  'meter': /^(value|min|max|low|high|optimum)$/
  'object': /^(data|type(mustmatch)?|name|usemap|form|width|height)$/
  'ol': /^(reversed|start|type)$/
  'optgroup': /^(disabled|label)$/
  'option': /^(disabled|label|selected|value)$/
  'p': /^(for|form|name)$/
  'param': /^(name|value)$/
  'progress': /^(value|max)$/
  'q': /^(cite)$/
  'script': /^(src|async|defer|type|charset)$/
  'select': /^(autofocus|disabled|form|multiple|name|required|size)$/
  'source': /^(src|type|media)$/
  'style': /^(media|type|scoped)$/
  'table': /^(border)$/
  'td': /^(colspan|rowspan|headers)$/
  'textarea': ///
    ^(
      autofocus | cols | dirname | disabled | form | maxlength | name | placeholder
      | readonly | required | rows | wrap
    )$
  ///
  'th': /^(colspan|rowspan|headers|scope|abbr)$/
  'time': /^(datetime)$/
  'track': /^(kind|src|srclang|label|default)$/
  'video': /^(src|crossorigin|poster|preload|autoplay|mediagroup|loop|muted|controls|width|height)$/

ATTR_BOOLEANS = /^(disabled|selected|checked|contenteditable)$/


#  JavaScript
#-----------------------------------------------
JS_RESERVED_WORDS = ///
  ^(
    break|case|catch|continue|debugger|default|delete|do|else|finally|for|function|if
    |in|instanceof|new|return|switch|this|throw|try|typeof|var|void|while|with|class|enum
    |export|extends|import|super|implements|interface|let|package|private|protected|public
    |static|yield|null|true|false
  )$
///

JS_GLOBAL_VARIABLES = ///
  ^(
    window|document|$|_
  )$
///

JS_NON_VARIABLE_REGEXP = ///
  (?: # hash key literal
    ({|,)
    \s*
    \w+:
  )
  |
  (?: # property access by dot notation
    \.
    [a-z]\w*
    (?:\.\w+)*
    \b
  )
  |
  (?: # function call
    \w+\s*\(
  )
///g

JS_VARIABLE_REGEXP = /\b[a-z]\w*/g


#  Errors
#-----------------------------------------------
class UnbalancedTagParseError extends Leaf.Error


#  Parser
#-----------------------------------------------
class Leaf.Template.Parser

  customTags = Leaf.Template.customTags

  constructor: ->

  init: (@buffer) ->
    unless @buffer?
      throw new RequiredArgumentsError('buffer')

    formatter = Leaf.Formatter.HTML
    @buffer = formatter.minify @buffer

    @tokenizer = new Leaf.Template.Tokenizer()
    @tokenizer.init @buffer

    @bindings = {}

    @root =
      name: '_root'
      contents: []
      scope: {}
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

  parseExpression: (expr) ->
    node = {}
    node.expr = expr
    node.vars = []

    return node unless expr

    buf = ''
    i = 0
    len = expr.length

    # strip string and regexp literal
    while i < len
      buf += (c = expr[i])

      if '\'' == c || '"' == c || '/' == c
        idx = i + 1
        true while ~(idx = expr.indexOf(c, idx)) && '\\' == expr[idx++ - 1]
        return node if (i = idx) == -1 # unbalance error
      else
        i++

    expr = buf.replace JS_NON_VARIABLE_REGEXP, '#'

    return node unless (m = expr.match JS_VARIABLE_REGEXP)

    node.vars = m.filter (arg) ->
      !arg.match(JS_RESERVED_WORDS) && !arg.match(JS_GLOBAL_VARIABLES)

    node.vars = _.uniq node.vars

    node

  parseTagAttrs: (node, attrs) ->
    node.attrs = {}
    node.attrBindings = {}
    node.localeBindings = {}
    node.actions = {}

    return unless attrs

    attrs = " #{attrs} "

    ATTR_REGEXP.lastIndex = 0

    while (m = ATTR_REGEXP.exec attrs)
      binding = m[1]
      key = m[2]
      val = m[3] || m[4]

      if '$' == binding
        globalAttrs = ATTR_PRESERVED['*']
        tagSpecificAttrs = ATTR_PRESERVED[node.name]

        if key.match(globalAttrs) || tagSpecificAttrs && key.match tagSpecificAttrs
          node.attrBindings[key] = @parseExpression val
        else
          node.localeBindings[key] = @parseExpression val
      else if '@' == binding
        node.actions[key] = val
      else
        node.attrs[key] = val

    ATTR_REGEXP.lastIndex = 0

  createNewScope: (node, parent) ->
    node.scope = _.merge _.clone(node.localeBindings), parent.scope

  createTagNode: (token, parent) ->
    node = {}
    node.type = token.type
    node.contents = []
    node.context = {}
    node.name = token.name
    @parseTagAttrs node, token.attrPart
    @createNewScope node, parent
    node

  createTextNode: (token) ->
    node = {}
    node.type = token.type
    node.buffer = token.buffer
    node

  createInterpolationNode: (token, parent) ->
    node = {}
    node.type = token.type
    node.escape = token.textBinding.escape
    expr = _.unescape token.textBinding.val
    node.value = @parseExpression expr
    node

  parseNode: (parents, token) ->
    p = parents[0]

    switch token.type
      when T_TEXT
        @customTagReset token, p
        node = @createTextNode token
        p.contents.push node
      when T_INTERPOLATION
        @customTagReset token, p
        node = @createInterpolationNode token, p
        p.contents.push node
      when T_TAG_SELF
        node = @createTagNode token, p
        @customTagOpenOther token, p
        @customTagOpen node, p
        p.contents.push node
      when T_TAG_OPEN
        node = @createTagNode token, p
        @customTagOpenOther token, p
        @customTagOpen node, p
        p.contents.push node
        parents.unshift node
      when T_TAG_CLOSE
        if token.name == p.name
          _p = parents.shift()
          p = parents[0]
          @customTagCloseOther _p, p
          @customTagClose _p, p
        else
          throw new UnbalancedTagParseError()

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


