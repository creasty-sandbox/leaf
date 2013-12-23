
###
# Polymorphic argument function
#
# @example:
# { $el, name, handler } = polymorphic
#   '.':   'name'
#   's.':  'name handler'
#   'o.':  '$el name'
#   '...': '$el name handler'
# , arguments
###
_.mixin polymorphic: do ->

  # types of each argument
  makeArrayOfTypes = (o) ->
    o.reduce (a, b) ->
      a + (if b? then Object::toString.call(b)[8...9] else '')
    , ''

  # sanitizing & regulation
  regularizePattern = (str) ->
    str.replace(/[^a-z\.\+\?\*]/ig, '').toUpperCase()

  # make group from argv
  getPartial = (argv, s) ->
    if s.isArray
      argv.splice 0, s.length
    else if s.length > 0
      argv.shift()

  # analyze pattern
  getSignature = (argt, pattern) ->
    _p = null
    signature = []

    while true
      t = argt[0]
      p = pattern[0]

      # buffer is empty
      break unless p

      if p == '.' || p == t
        signature.push [t]
        _p = pattern.shift()
        argt.shift()
      else if p == '?'
        signature.push [] unless _p
        pattern.shift()
      else if p == '*' || p == '+'
        s = signature[-1...][0] ? [] # last item
        s.isArray = true

        if !_p
          # no match found
          signature.push []
          pattern.shift()
        else if (_p == '.' || _p == t) && t != pattern[1]
          # in series
          s.push t
          argt.shift()
        else
          # end of series
          _p = null
          pattern.shift()
      else
        # optional or zero: `x?` or `x*`
        _p = null
        pattern.shift()

    signature

  # call function with grouped args
  callFunction = (argv, signature, scope) ->
    res = (getPartial argv, s for s in signature)
    vars.apply scope, res

  # group and name args by signature
  getNamedArgs = (vars, argv, signature) ->
    res = {}
    res[vars.shift()] = getPartial argv, s for s in signature
    res

  # polymorphic
  (def, argv, scope) ->
    # clone
    argv = [argv...]
    argt = makeArrayOfTypes argv

    # find match
    for pattern, vars of def
      pattern = regularizePattern pattern

      break if (match = new RegExp("^#{pattern}$").exec argt)

    return {} unless match

    # analyze
    argt = argt.split ''
    pattern = pattern.split ''
    signature = getSignature argt, pattern

    if _.isFunction vars
      callFunction argv, signature, scope
    else if _.isArray vars
      getNamedArgs vars, argv, signature
    else
      getNamedArgs vars.split(/\s+/), argv, signature

