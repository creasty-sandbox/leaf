
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
  (
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

TAG_SELF_CLOSING = /^(img|input|hr|br|wbr|outlet|render|component)$/


#  Tokenizer
#-----------------------------------------------
class Leaf.Template.Tokenizer

  constructor: (@buffer) ->
    @_buffer = @buffer
    @tokens = {}
    @index = 0

  getTag: (buffer) ->
    m = TAG_REGEXP.exec buffer

    return { type: T_NONE } unless m

    t = {}
    t.buffer = m[0]
    t.index = m.index
    t.length = t.buffer.length
    t.name = m[2]
    t.type =
      if m[1]
        T_TAG_CLOSE
      else if m[4] || t.name.match TAG_SELF_CLOSING
        T_TAG_SELF
      else
        T_TAG_OPEN
    t.attrPart = m[3] unless T_TAG_CLOSE == t.type

    t

  getInterpolation: (buffer) ->
    m = INTERPOLATION_REGEXP.exec buffer

    return { type: T_NONE } unless m

    t = {}
    t.type = T_INTERPOLATION
    t.buffer = m[2] # since m[1] is a hack
    t.index = m.index - m[1].length
    t.length = t.buffer.length

    t.textBinding =
      val: (m[3] || m[4]).trim()
      escape: !!m[4]

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

