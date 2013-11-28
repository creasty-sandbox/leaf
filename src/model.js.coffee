
class Leaf.Model

  @path: null

  @accessors = []
  @associations = []

  constructor: ->
    @init()
    @initAccessors()
    @initAssociations()


  #  Initializer
  #-----------------------------------------------
  init: ->
    @c = @constructor

    @params = {}
    @attrs = {}
    @locals = {}

    @dfd = $.Deferred()
    @promise = @dfd.promise()

  initAccessors: ->
    _(@c.accessors).forEach (accessor) =>
      table = @[if accessor.sync then 'attrs' else 'locals']
      @__defineGetter__ accessor.name, ->
        table[accessor.name]

      @__defineSetter__ accessor.name, (val) ->
        table[accessor.name] = val

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
  @attrAccessible: (attrs...) ->
    attrs.forEach (attr) => @accessors.push name: attr, sync: true

  @local: (attrs...) ->
    attrs.forEach (attr) => @accessors.push name: attr, sync: false

  @belongsTo: (assoc, options = {}) ->
    options.type = 'belongsTo'
    options.name = assoc
    @associations.push options

  @hasOne: (assoc, options = {}) ->
    options.type = 'hasOne'
    options.name = assoc
    @associations.push options

  @hasMany: (assoc, options = {}) ->
    options.type = 'hasMany'
    options.name = assoc
    @associations.push options

  @hasAndBelongsToMany: (assoc, options = {}) ->
    options.type = 'hasAndBelongsToMany'
    options.name = assoc
    @associations.push options

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

###

class window.Model

  @accessors = []

  constructor: (attrs = {}) ->
    @init()
    @initAccessors()

    @[attr] = val for attr, val of attrs

  #  Initializer
  #-----------------------------------------------
  init: ->
    @c = @constructor

    @attrs = {}
    @locals = {}

  initAccessors: ->
    @c.accessors.forEach (accessor) =>
      table = @[if accessor.sync then 'attrs' else 'locals']
      Object.defineProperty @, accessor.name,
        enumerable: true
        configurable: true
        get: =>
          table[accessor.name]
        set: (val) =>
          table[accessor.name] = val
          @change accessor.name

  change: (name) ->
    $(window).trigger 'change:model_user_1', [name, @]

  #  Static
  #-----------------------------------------------
  @attrAccessible: (attrs...) ->
    attrs.forEach (attr) =>
      @accessors.push name: attr, sync: true

  @attrAccessor: (attrs...) ->
    attrs.forEach (attr) =>
      @accessors.push name: attr, sync: false

###
