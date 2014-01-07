
class Leaf.Class extends Object

  constructor: ->
    @_superClass = @constructor.__super__

    @initialize arguments...

  initialize: ->

  getClass: -> @constructor

  @singleton: ->
    instance = new @ arguments...
    instance._sharedInstance = instance
    instance

  @mixin: -> Leaf.mixin @, arguments...
  mixin: -> Leaf.mixin @, arguments...
  initMixin: (mixins...) ->
    mixin.apply @ for mixin in mixins ? []

  inherit: (property) ->
    return unless @_superClass
    self = @[property] ? {}
    @[property] = _.defaults self, @_superClass[property]

