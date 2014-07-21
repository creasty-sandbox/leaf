_            = require 'lodash'
Keypath      = require './keypath'
KeypathEvent = require './keypath_event'


class KeypathEventTracker

  constructor: (@obj, @event) ->
    @_tracker = @_track.bind @

  _setup: ->
    @chainID = Keypath.sharedKeypath.chainID
    @_stack = []

    @obj.on @event, @_tracker

  _teardown: ->
    @obj.off @event, @_tracker
    @_stack = null

  _track: (e) ->
    return unless e instanceof KeypathEvent
    return unless e.keypathChainID == @chainID

    @_stack.pop() if e.propagated

    @_stack.push e.keypath

  track: (fn) ->
    @_setup()
    fn()
    stack = @_stack
    @_teardown()

    _.unique stack


module.exports = KeypathEventTracker
