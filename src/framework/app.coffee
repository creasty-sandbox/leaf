
class Leaf.App extends Leaf.Object

  @setLeafClass()

  basePath: '/'
  usePushState: true
  cacheViews: true

  views: {}
  yieldContents: {}

  constructor: (config = {}) ->
    super()
    Leaf.app = @

    @[key] = val for key, val of config

  registerView: (name, buffer) ->
    @views[name] = Leaf.View.parse buffer

  getPartial: (file, node) ->

  getYieldContentFor: (name, $marker) ->
    dfd = (@yieldContents[name] ?= $.Deferred())
    dfd.done ($view) ->
      $view.insertAfter $marker

  setYieldContentFor: (name, $view) ->
    dfd = (@yieldContents[name] ?= $.Deferred())
    dfd.resolve [$view]

  ###
  routes: (routes) ->
    return unless routes
    @router = new Leaf.Router()
    @router.createTable routes
  ###

