
class Leaf.Utils

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
  @polymorphic: (def, argv, scope) ->
    # clone
    argv = [argv...]
    # types of each argument
    argt = argv.reduce ((a, b) -> a + Object::toString.call(b)[8...9]), ''

    # find match
    for pattern, vars of def
      # sanitizing & regulation
      pattern = pattern.replace(/[^a-z\.\+\?\*]/ig, '').toUpperCase()

      break if (match = new RegExp("^#{pattern}$").exec argt)

    return {} unless match

    # arraynize
    argt = argt.split ''
    pattern = pattern.split ''

    # analyze
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

    getPartial = (s) ->
      if s.isArray
        argv.splice 0, s.length
      else if s.length > 0
        argv.shift()

    if 'function' == typeof vars
      # call function with grouped args
      res = (getPartial s for s in signature)
      vars.apply scope, res
    else
      # return named args
      res = {}
      vars = vars.split /\s+/
      res[vars.shift()] = getPartial s for s in signature
      res


  @bind: (str, args...) ->
    if _.isObject args[0]
      fn = (_0, name) -> args[0][name] ? _0
    else
      i = 0
      fn = (_0, name) -> args[i++] ? _0

    str.replace /:(\w+)/g, fn

  @extractOptions: (args) ->
    if _.isObject args[args.length - 1]
      args.pop()
    else
      {}

  @regulateUrl: (path) ->
    path = path.replace /\/+/g, '/'
    path = path.replace /([^\/]+)\/\1/g, '$1'
    path

  @filter: ({ only, except }) ->
    permit =
      index: true
      show: true
      edit: true

    if only
      only = [only] unless _.isArray only
      permit[p] = true for p in only

    if except
      except = [except] unless _.isArray except
      permit[p] = false for p in except

    permit


