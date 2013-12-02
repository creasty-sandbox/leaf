
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
TAG_REGEXP = /<(\/?)(\w+)([^>]*)(\/?)>/
TAG_SELF_CLOSING = /^(img|input|hr|br|wbr)$/

ATTR_REGEXP = /\s+(\$*)([\w\-]+)=(?:(?:\"([^\"]*?)\")|(?:\'([^\']*?)\'))/g
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

  constructor: (@html) ->
    @originalHtml = @html

  bindingFragment: (tag, key, val) ->
    tar = ATTR_PRESERVED[tag]

    if key.match(ATTR_PRESERVED['*']) || tar && key.match tar
      @token.attrBindings[key] = val
    else
      @token.localBindings[key] = val

  attrFragment: (pair, tag) ->
    attrs = " #{attrs} ".match ATTR_REGEXP

    for attr in attrs
      m = ATTR_REGEXP.exec attr
      binding = m[1]
      key = m[2]
      val = m[3] || m[4]

      if binding
        @bindingFragment tag, key, val
      else
        @token.attrs[key] = val

  tagFragment: (buffer) ->
    match = TAG_REGEXP.exec buffer

    return { type: T_NONE } unless match

    @token.buffer = match[0]
    @token.length = @token.buffer.length
    @token.name = match[2]
    @token.attrs = {}
    @token.attrBindings = {}
    @token.localBindings = {}
    @attrFragment match[3], @token.name

    t.type =
      if match[1]
        T_TAG_CLOSE
      else if match[4] || @token.name.match TAG_SELF_CLOSING
        T_TAG_SELF
      else
        T_TAG_OPEN

    t

  getToken: ->
    @token = {}



