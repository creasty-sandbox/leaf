
class Leaf.Template.Binder

  constructor: (@obj) ->

  getFunction: (expr, vars) ->
    new Function vars..., "return (#{expr})"

  getEvaluator: (fn, vars) ->
    evaluate = =>
      args = vars.map (v) => @obj._get v
      try fn.apply @obj, args

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


