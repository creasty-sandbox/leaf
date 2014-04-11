
class Leaf.AffectedKeypathTracker

  constructor: (@obj, @event) ->
    @_stack = []
    @_tracker = @track.bind @

    @setup()

  setup: ->
    @obj.on @event, @_tracker

  teardown: ->
    @obj.off @event, @_tracker
    @_stack = []

  track: (e) ->
    return unless e && e.keypath?

    if e.propagated
      idx = @_stack.lastIndexOf e.propagatedKeypath
      @_stack.splice idx, 1 if ~idx

    @_stack.push e.keypath

  getAffectedKeypaths: ->
    stack = @_stack
    @teardown()
    _.unique stack


