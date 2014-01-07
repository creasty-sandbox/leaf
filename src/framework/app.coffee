
class Leaf.App extends Leaf.Object

  @setObjectType()

  basePath: '/'
  usePushState: true
  cacheViews: true

  views: {}

  constructor: (config = {}) ->
    super()
    Leaf.app = @

    @[key] = val for key, val of config

  ###
  routes: (routes) ->
    return unless routes
    @router = new Leaf.Router()
    @router.createTable routes
  ###

