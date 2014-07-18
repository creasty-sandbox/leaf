singleton  = require '../utils/singleton'
Accessible = require '../utils/accessible'


class Keypath

  singleton @, 'Keypath'

  constructor: ->
    @_chains = []
    @beginChain()

  addKey: (key) ->
    self = @

    Accessible.sharedAccessible.accessor key,
      get: ->
        id = ++self._chains[self.chainId].id
        @get key, id, self.chainId
      set: (val) ->
        id = ++self._chains[self.chainId].id
        @set key, val, id, self.chainId

  beginChain: ->
    @_chains.push id: 0
    @chainId = @_chains.length - 1

  endChain: ->
    @chainId = --@_chains.length - 1


module.exports = Keypath
