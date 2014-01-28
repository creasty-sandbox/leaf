
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
    className = (name + '_component').classify()
    @app[className]

  getModelClassFor: (name) ->
    className = (name + '').classify()
    @app[className]

  getControllerClassFor: (name) ->
    className = (name + '_controller').classify()



# Framework namespace
window.Leaf = Leaf = new Leaf()

