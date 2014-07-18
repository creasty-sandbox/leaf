JS_STRING_LITERAL_DELIMITER_1 = '"'
JS_STRING_LITERAL_DELIMITER_2 = "'"
JS_REGEXP_LITERAL_DELIMITER   = '/'
JS_REGEXP_LITERAL_FLAGS       = /[gimy]/
JS_CONTEXT_BORDERS            = /[{(\[\-+=!&|:;,?]/


jsIdent = (js, i = 0, callback) ->
  return '' unless js

  len = js.length

  buf = ''
  prev = ''

  # strip string and regexp literal
  while i < len
    c = js[i]

    if (
      JS_STRING_LITERAL_DELIMITER_1 == c \
      || JS_STRING_LITERAL_DELIMITER_2 == c \
      || (
        JS_REGEXP_LITERAL_DELIMITER == c \
        && prev.match JS_CONTEXT_BORDERS # slash as division
      )
    )
      buf += ' '
      idx = i + 1

      true while ~(idx = js.indexOf(c, idx)) && '\\' == js[idx++ - 1]

      if idx == -1
        # unbalance, skip anyway
        ++i
        continue
      else
        if JS_REGEXP_LITERAL_DELIMITER == c
          # strip flags
          ++idx while js[idx].match JS_REGEXP_LITERAL_FLAGS

        buf += Array(idx - i).join ' '
        i = idx
    else
      buf += c
      prev = c unless c.match /\s/
      ++i

      if callback?
        break unless callback c, i

  buf


module.exports = jsIdent
