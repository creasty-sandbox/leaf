singleton = require './singleton'


class Accessible

  singleton @, 'Accessible'

  constructor: ->
    @_accessors = {}

  get: -> @
  set: (val) -> @

  accessor: (key, desciptor) ->
    return if @_accessors[key]
    @_accessors[key] = desciptor
    Object.defineProperty @, key, desciptor

  @ontoClass: (klass) ->
    klass::__proto__ = @sharedAccessible


module.exports = Accessible
