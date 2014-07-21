Event   = require '../event'
Keypath = require './keypath'


class KeypathEvent extends Event

  constructor: ->
    super

    @keypath        ?= ''
    @keypathChainID = Keypath.sharedKeypath.chainID


module.exports = KeypathEvent
