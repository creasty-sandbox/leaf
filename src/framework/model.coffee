
class Leaf.Model extends Leaf.Object

  @path: null

  @accessors = []
  @associations = {}

  @defaultAttrs = {}

  constructor: (_data) ->
    super()

    _data = _.defaults _data, @constructor.defaultAttrs
    @setData _data, false

    @modelName = @constructor.name

    @params = {}

    @dfd = $.Deferred()
    @promise = @dfd.promise()

    @_initAccessors()
    @_initAssociations()

  #  Initializer
  #-----------------------------------------------
  initialize: ->

  _initAccessors: ->
    _(@constructor.accessors).forEach (accessor) =>
      @_accessor accessor.name

  _initAssociations: ->
    for assoc, options of @constructor.associations
      @[assoc] = new Leaf.ObservableArray()

  #  Override settings
  #-----------------------------------------------
  path: (path) ->
    if path?
      @_path = path
      @
    else
      @_path ? @c.path

  #  Scopes
  #-----------------------------------------------
  find: (id) ->
    # todo
    @params.id = id >>> 0
    @

  where: (cond) ->
    _.extend @params, cond

    @

  all: -> @

  order: (order, direction = 'asc') ->
    @params.order_by = order if order?
    @params.order_dir = direction
    @

  per: (num) ->
    @params.per = num >>> 0 if num?
    @

  page: (page) ->
    @params.page = page >>> 0 if page?
    @

  limit: (limit) ->
    @params.limit = limit >>> 0 if limit?
    @

  #  Sync
  #-----------------------------------------------
  update: (attrs = {}) ->
    @

  fetch: (params = {}) ->
    params = _.extend {}, @params, params

    @dfd.resolve()
    # todo
    @

  save: ->
    @

  #  Deferred
  #-----------------------------------------------
  done: (callback) -> @promise.done callback
  fail: (callback) -> @promise.fail callback
  then: (done, fail) -> @promise.then done, fail

  #  Attributes & associations
  #-----------------------------------------------
  @attrAccessible: (name, options = {}) ->
    @accessors.push name: name, sync: true

    if options.defaults
      @defaultAttrs[name] = options.defaults

  @attrAccessor: (name, options = {}) ->
    @accessors.push name: name, sync: false

  @belongsTo: (assoc, options = {}) ->
    options.type = 'belongsTo'
    options.name = assoc
    @associations[assoc] = options

  @hasOne: (assoc, options = {}) ->
    options.type = 'hasOne'
    options.name = assoc
    @associations[assoc] = options

  @hasMany: (assoc, options = {}) ->
    options.type = 'hasMany'
    options.name = assoc
    @associations[assoc] = options

  @hasAndBelongsToMany: (assoc, options = {}) ->
    options.type = 'hasAndBelongsToMany'
    options.name = assoc
    @associations[assoc] = options

  #  Static with-initializer methods
  #-----------------------------------------------
  @create: (args...) -> new @(args...)

  [
    'path'
    'find'
    'where'
    'all'
    'order'
    'per'
    'page'
    'limit'
  ].forEach (method) =>
    @[method] = (args...) -> new @()[method] args...

