
class Leaf

  LOCAL_SERVER = /(^localhost$)|(\.(dev|local)$)/

  app: null
  develop: false

  constructor: ->
    @develop = !!window.location.hostname.match LOCAL_SERVER

  log: (args...) ->
    return unless @develop
    msg = ['[Leaf] Log:', args...]
    console.log msg...

  warn: (args...) ->
    return unless @develop
    msg = ['[Leaf] Warn:', args...]
    console.error msg...


# Framework namespace
window.Leaf = new Leaf()

