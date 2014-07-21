_          = require 'lodash'
singleton  = require '../utils/singleton'
Accessible = require '../utils/accessible'
Cache      = require '../utils/cache'


class Keypath

  singleton @, 'Keypath'

  @regulateCache = new Cache 'keypath:regulate'
  @ancestorsCache = new Cache 'keypath:ancestors'

  constructor: ->
    @chainID = 0

  addKey: (key) ->
    Accessible.sharedAccessible.accessor key,
      get: -> @_get key
      set: (val) -> @_set key, val

  chain: (fn) ->
    ++@chainID
    try fn()
    --@chainID

  @build: (paths...) -> _.compact(paths).join '.'

  @regulate: (keypath) ->
    return '' unless keypath?

    @regulateCache.findOrCreate keypath, ->
      String(keypath)
      .replace(/^this\.?/, '')
      .replace(/\[(\d+)\]/g, '.$1')

  @ancestors: (keypath) ->
    keypath = @regulate keypath

    @ancestorsCache.findOrCreate keypath, ->
      paths = keypath.split '.'
      ancestors = [keypath]
      ancestors.push paths.join('.') while paths.pop() && paths[0]
      ancestors


module.exports = Keypath
