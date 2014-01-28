
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

  hasApp: -> !!@app

  getComponentClassFor: (name) ->
    className = "#{(name + '').classify()}Component"
    Leaf.app[className]


# Framework namespace
window.Leaf = Leaf = new Leaf()

