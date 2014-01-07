
class LeafObject extends Leaf.Class

  constructor: ->
    @initMixin Leaf.Identifiable,
      Leaf.Cacheable,
      Leaf.Accessible,
      Leaf.Hookable,
      Leaf.ObservableObject

    @_superClass = @constructor.__super__

    super arguments...

  @_isLeafObject: true
  __isLeafObject: true

  inherit: (property) ->
    return unless @_superClass
    self = @[property] ? {}
    @[property] = _.defaults self, @_superClass[property]

  toString: -> "<#{@getLeafClass()}.#{@constructor.name} #{@_leafID}>"

  getLeafClass: -> "Leaf.#{@constructor._objectType}"

  @setObjectType: (name = @name) -> @_objectType = name

  # self
  @setObjectType()

  @mixin Leaf.Cacheable,
    Leaf.Accessible,
    Leaf.Hookable,
    Leaf.ObservableObject


Leaf.Object = LeafObject


