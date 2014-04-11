
JS_RESERVED_WORDS = ///
  ^(
    break|case|catch|continue|debugger|default|delete|do|else|finally|for|function|if
    |in|instanceof|new|return|switch|this|throw|try|typeof|var|void|while|with|class|enum
    |export|extends|import|super|implements|interface|let|package|private|protected|public
    |static|yield|null|true|false
  )$
///

JS_EXCLUDED_VARIABLES = /^(window|document|$|_|self)$/

JS_NON_VARIABLE_REGEXP = ///
  (?: # hash key literal
    ({|,)
    \s*
    \w+\s*:
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


class Leaf.ExpressionCompiler

  _scopedExpressionCache = {}

  constructor: (@obj, @self) ->
    @_evaluators = {}
    @_dependents = {}

  scopedExpression: (expr) ->
    return '' unless expr

    return _scopedExpressionCache[expr] if _scopedExpressionCache[expr]
    _scopedExpressionCache[expr] = ''

    buf = ''
    i = 0
    len = expr.length

    # strip string and regexp literal
    while i < len
      buf += (c = expr[i])

      if '\'' == c || '"' == c || '/' == c
        idx = i + 1
        true while ~(idx = expr.indexOf(c, idx)) && '\\' == expr[idx++ - 1]
        buf += Array(idx - i).join c
        return '' if (i = idx) == -1 # unbalance: expression has syntax error
      else
        i++

    # expression that only contains local variables
    vars = buf.replace JS_NON_VARIABLE_REGEXP, (str) -> Array(str.length + 1).join '#'

    # gather indexes of local variables
    JS_VARIABLE_REGEXP.lastIndex = 0

    varsAt = []

    while (m = JS_VARIABLE_REGEXP.exec vars)
      varsAt.push m.index if !m[0].match(JS_RESERVED_WORDS) && !m[0].match(JS_EXCLUDED_VARIABLES)

    JS_VARIABLE_REGEXP.lastIndex = 0

    # add scope references to local variables
    expr = expr.split ''

    i = varsAt.length
    expr.splice varsAt[i], -1, 'self.' while i--

    _scopedExpressionCache[expr] = expr.join ''

  makeGetter: (expr, orgExpr) ->
    try
      new Function 'self', "return (#{expr})"
    catch e
      Leaf.warn 'Syntax error:', orgExpr
      (->)

  getEvaluator: (expr) ->
    return @_evaluators[expr] if @_evaluators[expr]

    getter = @makeGetter @scopedExpression(expr), expr

    evaluator = =>
      try
        getter.call @obj, @self
      catch e
        Leaf.warn 'Invalid expression:', expr
        ''

    @_evaluators[expr] = evaluator

  createBinder: (expr, bind) ->
    evaluator = @getEvaluator expr

    tracker = new Leaf.AffectedKeypathTracker @obj, 'get' unless @_dependents[expr]

    res = evaluator()

    if tracker
      dependents = tracker.getAffectedKeypaths()
      @_dependents[key] = dependents

      _(dependents).forEach (dependent) =>
        @obj.observe dependent, ->
          bind evaluator()

    bind res

  evalObject: (pairs) ->
    obj = new Leaf.ObservableObject()

    _(pairs).forEach (expr, key) =>
      @createBinder expr, (res) ->
        obj.set key, res

    obj

  eval: (expr) -> @getEvaluator(expr)()


