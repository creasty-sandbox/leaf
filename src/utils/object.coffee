
class LeafObject extends Leaf.Class

  constructor: ->
    @initMixin Leaf.Identifiable,
      Leaf.Cacheable,
      Leaf.Accessible,
      Leaf.Hookable,
      Leaf.ObservableObject

    super arguments...

  @_isLeafObject: true
  __isLeafObject: true

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


