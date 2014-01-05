
class LeafObject extends Object

  @_objectType = 'Object'

  _leafID = 0

  constructor: -> @_objectBaseInit()

  getClass: -> @constructor

  @singleton: ->
    instance = new @ arguments...
    instance._sharedInstance = instance
    instance

  _objectBaseInit: ->
    @_leafObject = true
    @_leafID = ++_leafID
    @_superClass = @constructor.__super__
    @_cache = new Leaf.Cache()
    @_cache.set @toLeafID(), @
    @_accessors = {}

  @mixin: -> @::mixin.apply @::, arguments
  mixin: -> Leaf.mixin @, arguments...
  initMixin: (mixin, args...) -> mixin.apply @, args

  inherit: (property) ->
    return unless @_superClass
    self = @[property] ? {}
    @[property] = _.defaults self, @_superClass[property]

  accessors: (accessors, obj = @) ->
    return unless accessors
    @_accessor attr, obj for attr in accessors

  removeAccessors: (accessors, obj = @) ->
    return unless accessors
    @_removeAccessor attr, obj for attr in accessors

  _accessor: (attr, obj = @) ->
    @_accessors[attr] = 1

    Object.defineProperty @, attr,
      enumerable: true
      configurable: true
      get: => obj._get attr
      set: (val) => obj._set attr, val

  _removeAccessor: (attr, obj = @) ->
    @_accessors[attr] = undefined

    Object.defineProperty obj, attr,
      enumerable: false
      configurable: true
      value: undefined

  toString: -> "<#{@getLeafClass()}.#{@constructor.name} #{@_leafID}>"

  toLeafID: -> "__LEAF_ID_#{@_leafID}"

  getLeafClass: -> "Leaf.#{@constructor._objectType}"

  @isLeafID: (id) ->
    return false unless _.isString id
    !!id.match /^__LEAF_ID_\d+$/

  @setObjectType: (name = @name) -> @_objectType = name


Leaf.Object = LeafObject


