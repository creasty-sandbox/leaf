
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
    [$_a-z][$\w]*\s*:
  )
  |
  (?: # property access by dot notation
    \.
    [$_a-z][$\w]*
    (?:\.[$\w]+)*
    \b
  )
  |
  (?: # function call
    [$_a-z][$\w]*\s*\(
  )
///g

JS_VARIABLE_REGEXP = /([\b$]|\b[_a-z])[$\w]*/g


class Leaf.ExpressionCompiler

  _scopedExpressionCache = {}

  constructor: (@obj, @scope) ->
    @_scopeVar = 'self'
    @_evaluators = {}
    @_dependents = {}

  scopedExpression: (expr) ->
    return '' unless expr

    return _scopedExpressionCache[expr] if _scopedExpressionCache[expr]
    _scopedExpressionCache[expr] = ''

    # expression that only contains local variables
    buf = Leaf.Util.removeJsLiterals expr
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
    expr.splice varsAt[i], -1, "#{@_scopeVar}." while i--

    _scopedExpressionCache[expr] = expr.join ''

  makeGetter: (expr, orgExpr) ->
    try
      new Function @_scopeVar, "return (#{expr})"
    catch e
      Leaf.warn 'Syntax error:', orgExpr
      (->)

  getEvaluator: (expr) ->
    return @_evaluators[expr] if @_evaluators[expr]

    getter = @makeGetter @scopedExpression(expr), expr

    evaluator = =>
      try
        getter.call @obj, @scope
      catch e
        Leaf.warn 'Invalid expression:', expr
        ''

    @_evaluators[expr] = evaluator

  bind: (expr, routine) ->
    evaluator = @getEvaluator expr

    unless @_dependents[expr]
      tracker = new Leaf.AffectedKeypathTracker @obj, 'get'
      trackerOnScope = new Leaf.AffectedKeypathTracker @scope, 'get' if @scope

    res = evaluator()

    unless @_dependents[expr]
      dependents = tracker.getAffectedKeypaths()
      dependentsOnScope = trackerOnScope.getAffectedKeypaths() if @scope

      @_dependents[expr] = { dependents, dependentsOnScope }

      _(dependents).forEach (dependent) =>
        @obj.observe dependent, -> routine evaluator()

      if @scope
        _(dependentsOnScope).forEach (dependent) =>
          @scope.observe dependent, -> routine evaluator()

    routine res

  evalObject: (pairs, obj) ->
    obj ?= new Leaf.ObservableObject()

    _(pairs).forEach (expr, key) =>
      return unless expr?
      @bind expr, (res) -> obj.set key, res, withoutDelegation: true

    obj

  eval: (expr) -> @getEvaluator(expr)()


