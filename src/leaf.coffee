
class Leaf

  LOCAL_SERVER = /(^localhost$)|(\.(dev|local)$)/

  sharedEvent: null
  sharedApp: null
  develop: false
  context: null

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

  hasApp: -> !!@sharedApp

  getComponentClassFor: (name) ->
    className = "#{name.replace(/^component:/, '')}_component".classify()
    @sharedApp[className]

  getModelClassFor: (name) ->
    className = (name + '').classify()
    @sharedApp[className]

  getControllerClassFor: (name) ->
    className = "#{name}_controller".classify()


# Framework namespace
Leaf = new Leaf()
(Leaf.context = @).Leaf = Leaf

