
class LeafObject extends Leaf.Class

  __leafObject: true

  @setLeafClass 'Object'

  @mixin Leaf.Cacheable,
    Leaf.Accessible,
    Leaf.Hookable,
    Leaf.ObservableObject

  constructor: ->
    @initMixin Leaf.Cacheable,
      Leaf.Accessible,
      Leaf.Hookable,
      [Leaf.ObservableObject, @_observableData]

    @_superClass = @constructor.__super__

    @initialize arguments...

  initialize: ->

  inherit: (property) ->
    return unless @_superClass
    self = @[property] ? {}
    @[property] = _.defaults self, @_superClass[property]

  toString: -> "<#{@getLeafClass()}.#{@constructor.name} #{@_leafID}>"


Leaf.Object = LeafObject

