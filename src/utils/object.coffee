
class LeafObject extends Leaf.Class

  __leafObject: true

  constructor: ->
    @initMixins()

    @_superClass = @constructor.__super__

    @initialize arguments...

  initialize: ->

  inherit: (property) ->
    return unless @_superClass
    self = @[property] ? {}
    @[property] = _.defaults self, @_superClass[property]

  toString: -> "<#{@getLeafClass()}.#{@constructor.name} #{@_leafID}>"

  getLeafClass: -> "Leaf.#{@constructor._objectType}"

  @setLeafClass: (name = @name) -> @_objectType = name

  # self
  @setLeafClass 'Object'

  @mixin Leaf.Cacheable,
    Leaf.Accessible,
    Leaf.Hookable,
    Leaf.ObservableObject


Leaf.Object = LeafObject


