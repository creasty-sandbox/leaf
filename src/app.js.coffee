
class Leaf.App extends Leaf.Object

  @_objectType = 'App'

  basePath: '/'
  usePushState: true
  cacheViews: true

  constructor: ->
    super()
    @_c.app = @
    @appName = @_c.name
    @observer = new Leaf.Event()
    @connectAllObjects()

  connectAllObjects: ->
    obj.app = @ for own ns, obj of @_c when obj._objectType

  @routes: (routes) ->
    app = new @()
    # @router = new Leaf.Router app
    # @router.createTable routes

