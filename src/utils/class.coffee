
class Leaf.Class extends Object

  constructor: -> @initialize arguments...

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

