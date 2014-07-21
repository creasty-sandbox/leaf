_                   = require 'lodash'
ExpressionCompiler  = require './expression_compiler'
KeypathEventTracker = require './keypath_event_tracker'
ObservableObject    = require './observable_object'


class Binder

  constructor: (@obj, @scope) ->
    @_compiler = new ExpressionCompiler @obj, @scope

  bind: (expr, routine) ->
    evaluator = @_compiler.getEvaluator expr

    tracker = new KeypathEventTracker @obj, 'get'
    trackerOnScope = new KeypathEventTracker @scope, 'get' if @scope

    res = null
    dependents = null
    dependentsOnScope = null

    dependents = tracker.track =>
      if @scope
        dependentsOnScope = trackerOnScope.track =>
          res = evaluator()
      else
        res = evaluator()

    if dependents
      dependents.forEach (dependent) =>
        @obj.observe dependent, -> routine evaluator()

    if dependentsOnScope
      dependentsOnScope.forEach (dependent) =>
        @scope.observe dependent, -> routine evaluator()

    routine res

  createBindedValueObject: (pairs, obj) ->
    obj ?= new ObservableObject()

    _(pairs).forEach (expr, key) =>
      return unless expr?
      @bind expr, (res) -> obj.set key, res, withoutDelegation: true

    obj


module.exports = Binder
