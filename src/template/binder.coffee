
class Leaf.Template.Binder

  constructor: (@obj) ->

  getFunction: (expr, vars) ->
    try
      fn = new Function vars..., "return (#{expr})"
      fn.expr = expr
      fn
    catch e
      Leaf.warn 'Syntax error:', expr
      _.noop

  getEvaluator: (fn, vars) ->
    evaluate = =>
      args = vars.map (v) => @obj._get v
      try
        fn.apply @obj, args
      catch e
        Leaf.warn 'Invalid expression:', fn.expr
        return ''

  getBinder: ({ expr, vars }) ->
    value = @getFunction expr, vars

    evaluate = @getEvaluator value, vars

    bind = (routine) =>
      @obj._beginTrack 'getter' unless value._dependents

      result = evaluate()

      if (dependents = @obj._endTrack 'getter')
        value._dependents = dependents
        @obj.observe d, (-> routine evaluate()) for d in dependents

      routine result

  getBindingObject: (values) ->
    obj = new Leaf.Observable {}

    _(values).forEach (value, name) =>
      if value.raw
        obj.set name, value.rawValue
      else
        bind = @getBinder value
        bind (result) -> obj.set name, result

    obj

  getBindingValue: ({ expr, vars, raw, rawValue }) ->
    return rawValue if raw

    value = @getFunction expr, vars
    evaluate = @getEvaluator value, vars
    evaluate()

