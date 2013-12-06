
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
T_INTERPOLATION = 5


#  Patterns
#-----------------------------------------------
INTERPOLATION_REGEXP = ///
  (?:
    # negative lookbehind hack for js
    # don't match with escaped `{`
    ^|[^\\]
  )
  (
    (?:\{\{\{(.+?)\}\}\}) # raw print
    | (?:\{\{(.+?)\}\})   # safe print
  )
///

TAG_REGEXP = ///
  <
    (/?)    # closing tag
    (\w+)   # tag name
    ([^>]*) # attributes
    (/?)    # self closing
  >
///

ATTR_REGEXP = ///
  \s+       # need spaces seperater
  (\$|\@|)  # $ or @ or nothing
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
    @_buffer = @buffer
    @tokens = {}
    @index = 0

  tagAttrActionFragment: (t, eventName, handler) ->
    t.actions[eventName] = handler

  tagAttrBindingFragment: (t, property, val, tag) ->
    globalAttrs = ATTR_PRESERVED['*']
    tagSpecificAttrs = ATTR_PRESERVED[tag]

    if property.match(globalAttrs) || tagSpecificAttrs && property.match tagSpecificAttrs
      t.attrBindings[property] = val
    else
      t.localeBindings[property] = val

  tagAttrNormalFragment: (t, property, val) ->
    t.attrs[property] = val

  tagAttrFragments: (t, attrs, tag) ->
    t.attrs = {}
    t.attrBindings = {}
    t.localeBindings = {}
    t.actions = {}

    ATTR_REGEXP.lastIndex = 0
    attrs = " #{attrs} ".match ATTR_REGEXP

    return unless attrs

    for attr in attrs
      ATTR_REGEXP.lastIndex = 0
      m = ATTR_REGEXP.exec attr

      binding = m[1]
      key = m[2]
      val = m[3] || m[4]

      if '$' == binding
        @tagAttrBindingFragment t, key, val, tag
      else if '@' == binding
        @tagAttrActionFragment t, key, val
      else
        @tagAttrNormalFragment t, key, val

  getTag: (buffer) ->
    m = TAG_REGEXP.exec buffer

    return { type: T_NONE } unless m

    t = {}
    t.buffer = m[0]
    t.index = buffer.indexOf t.buffer
    t.length = t.buffer.length
    t.name = m[2]
    t.type =
      if m[1]
        T_TAG_CLOSE
      else if m[4] || t.name.match TAG_SELF_CLOSING
        T_TAG_SELF
      else
        T_TAG_OPEN

    unless T_TAG_CLOSE == t.type
      @tagAttrFragments t, m[3], t.name

    t

  getInterpolation: (buffer) ->
    m = INTERPOLATION_REGEXP.exec buffer

    return { type: T_NONE } unless m

    t = {}
    t.type = T_INTERPOLATION
    t.buffer = m[1] # since m[0] includes hack
    t.index = buffer.indexOf t.buffer
    t.length = t.buffer.length

    t.textBinding =
      val: (m[2] || m[3]).trim()
      escape: !!m[3]

    t

  getText: (buffer) ->
    return { type: T_NONE } unless buffer

    t = {}
    t.type = T_TEXT
    t.buffer = buffer
    t.index = 0
    t.length = buffer.length
    t

  getIndexTillInterpolation: ->
    max = @buffer.length + 1

    return max if @_noMoreInterpolation

    token = @getInterpolation @buffer

    if T_NONE == token.type
      @_noMoreInterpolation = true
      max
    else
      @tokens[@index + token.index] = token
      token.index

  getIndexTillTag: ->
    max = @buffer.length + 1

    return max if @_noMoreTags

    token = @getTag @buffer

    if T_NONE == token.type
      @_noMoreTags = true
      max
    else
      @tokens[@index + token.index] = token
      token.index

  eat: (token) ->
    len = token.length >>> 0
    @buffer = @buffer[len...]
    @index += len
    token

  getToken: ->
    if (token = @tokens[@index])
      @tokens[@index] = null
      return @eat token

    tt = @getIndexTillTag()
    ti = @getIndexTillInterpolation()

    return @getToken() if tt == 0 || ti == 0

    tx = Math.min tt, ti

    token = @getText @buffer[0...tx]
    @eat token

