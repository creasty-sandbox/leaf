
#  Token types
#-----------------------------------------------
T_NONE          = 'T_NONE'
T_TAG           = 'T_TAG'
T_TEXT          = 'T_TEXT'
T_INTERPOLATION = 'T_INTERPOLATION'


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
    (/?)       # closing tag
    ([\w\-:]+) # tag name
    ( # attributes
      (?:
        \s+         # need spaces seperater
        (?:\$|\@|)  # $ or @ or nothing
        (?:[\w\-]+) # property name
        (?:         # has value?
          =
          (?:
            (?:\"(?:[^\"]*?)\")   # double quotes
            | (?:\'(?:[^\']*?)\') # single quotes
          )
        )?
      )*
    )
    \s*
    (/?) # self closing
  >
///i


#  Tokenizer
#-----------------------------------------------
class Leaf.Template.Tokenizer

  constructor: (@buffer) ->
    unless @buffer?
      throw new RequiredArguments 'buffer'

    @_buffer = @buffer
    @tokens = {}
    @index = 0

  getTag: (buffer) ->

    m = TAG_REGEXP.exec buffer

    return { type: T_NONE } unless m

    t = {}
    t.type = T_TAG
    t.buffer = m[0]
    t.index = m.index
    t.length = t.buffer.length
    t.name = m[2].toLowerCase()
    t.closing = !!m[1]
    t.selfClosing = !!m[4]
    t.attrPart = m[3] unless t.closing

    t

  getInterpolation: (buffer) ->
    m = INTERPOLATION_REGEXP.exec buffer

    return { type: T_NONE } unless m

    t = {}
    t.type = T_INTERPOLATION
    t.buffer = m[2] # since m[1] is a hack
    t.index = m.index + m[1].length
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

