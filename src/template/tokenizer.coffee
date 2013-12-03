
class HtmlPreformatter

  constructor: (@html) ->

  minify: ->
    @html = @html
      .replace(/\s+/g, ' ')
      .replace />\s+</g, '><'

  getHtml: -> @html


#  Token types
#-----------------------------------------------
T_NONE = 0
T_TAG_OPEN = 1
T_TAG_CLOSE = 2
T_TAG_SELF = 3
T_TEXT = 4
T_TEXT_INTERP = 5


#  Patterns
#-----------------------------------------------
TEXT_INTERP_REGEXP = ///
  (?: # negative lookbehind hack for js
    ^|[^\\] # don't match with escaped `{`
  )
  (
    (?:\{\{\{(.+?)\}\}\}) # raw print
    | (?:\{\{(.+?)\}\})   # safe print
  )
///g

TAG_REGEXP = ///
  <
    (\/?)   # closing tag
    (\w+)   # tag name
    ([^>]*) # attributes
    (\/?)   # self closing
  >
///g

ATTR_REGEXP = ///
  \s+ # need spaces seperater
  (\$|\@) # $ or @
  ([\w\-]+) # property name
  =
  (?:
    (?:\"([^\"]+?)\")   # double quotes
    | (?:\'([^\']+?)\') # single quotes
  )
///g

TAG_SELF_CLOSING = /^(img|input|hr|br|wbr|outlet|render|component)$/

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


#  Tokenizer
#-----------------------------------------------
class Tokenizer

  constructor: (@buffer) ->
    @next = []

  none: -> { type: T_NONE }

  action: (t, eventName, handler) ->
    t.actions[eventName] = handler

  binding: (t, tag, key, val) ->
    globalAttrs = ATTR_PRESERVED['*']
    tagSpecificAttrs = ATTR_PRESERVED[tag]

    if key.match(globalAttrs) || tagSpecificAttrs && key.match tagSpecificAttrs
      t.attrBindings[key] = val
    else
      t.localBindings[key] = val

  tagAttr: (t, attrs, tag) ->
    t.attrs = {}
    t.attrBindings = {}
    t.localBindings = {}
    t.actions = {}

    attrs = " #{attrs} ".match ATTR_REGEXP

    for attr in attrs
      m = ATTR_REGEXP.exec attr
      binding = m[1]
      key = m[2]
      val = m[3] || m[4]

      if '$' == binding
        @binding t, tag, key, val
      else if '@' == binding
        @action t, key, val
      else
        t.attrs[key] = val

  getTag: (buffer) ->
    m = TAG_REGEXP.exec buffer

    return @none() unless m

    t = {}
    t.buffer = m[0]
    t.index = buffer.indexOf t.buffer
    t.length = t.buffer.length
    t.name = m[2]
    @tagAttr t, m[3], t.name

    t.type =
      if m[1]
        T_TAG_CLOSE
      else if m[4] || t.name.match TAG_SELF_CLOSING
        T_TAG_SELF
      else
        T_TAG_OPEN

    t

  getInterpolation: (buffer) ->
    m = TEXT_INTERP_REGEXP.exec buffer

    return @none() unless m

    t = {}
    t.buffer = m[1] # since m[0] includes hack
    t.index = buffer.indexOf t.buffer
    t.length = t.buffer.length

    t.textBinding =
      val: m[2] || m[3]
      escape: !!m[3]

    t

  getText: (buffer) ->
    text = []

    for interp in interps
      token = @getInterporation buffer

      if T_NONE == token.type
        @getText
        buffer

  getFragments: ->
    return @none() unless @buffer

    tagToken = @getTag @buffer

    if T_NONE == tagToken.type
      @buffer = ''
      return tagToken

    textNode = @buffer[0...@token.index]
    @next.unshift @getText textNode

    @buffer = @buffer[(@token.index + @token.length)...]

  matchIndexOf: (buffer, pattern, offset = 0) ->
    m = buffer.match pattern
    return -1 unless m
    buffer.indexOf m[0], offset

  getChunk: ->
    tagIndex = @matchIndexOf @buffer, TAG_REGEXP

    if 0 == tagIndex
      t = @getTag @buffer
      @buffer = @buffer[0...t.length]
      return t
    else if tagIndex > 0
      interpolationIndex


  getToken: ->
    next = @next.pop()
    return next if next

    @getFragments()

    @next.shift()

