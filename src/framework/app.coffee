
class Leaf.App extends Leaf.Object

  @setLeafClass()

  basePath: '/'
  usePushState: true
  cacheViews: true

  views: {}

  constructor: (config = {}) ->
    super()
    Leaf.app = @

    @[key] = val for key, val of config

  registerView: (name, buffer) ->
    @views[name] = Leaf.View.parse buffer

  ###
  routes: (routes) ->
    return unless routes
    @router = new Leaf.Router()
    @router.createTable routes
  ###

