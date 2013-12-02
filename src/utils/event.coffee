
class Leaf.Event

  constructor: (@obj = {}) ->
    @obj._leafEventObj ?= $ {}
    @$obj = @obj._leafEventObj

  cls = @

  'on off one trigger'
  .split(' ').forEach (method) ->
    cls::[method] = -> @$obj[method] arguments...

