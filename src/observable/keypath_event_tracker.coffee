_       = require 'lodash'
Keypath = require './keypath'


class KeypathEventTracker

  constructor: (@obj, @event) ->
    @_tracker = @track.bind @
    @setup()

  setup: ->
    @chainId = Keypath.sharedKeypath.chainId
    @_stack = []
    @_lastKeypathId = -1

    @obj.on @event, @_tracker

  teardown: ->
    @obj.off @event, @_tracker
    @_stack = null

  track: (e) ->
    return unless e && e.keypath
    return unless e.keypathChainId == @chainId

    @_stack.pop() if e.propagated && e.keypathId == @_lastKeypathId + 1

    @_lastKeypathId = e.keypathId
    @_stack.push e.keypath

  getActiveKeypaths: ->
    stack = @_stack
    @teardown()
    _.unique stack


module.exports = KeypathEventTracker
