
class Leaf.Router

  constructor: (@config, @table = [], @options = {}) ->
    @rootPath = @options.path ? @config.basePath

    if @options.controller
      @currentPath = "#{@rootPath}/#{@options.controller}"
    else
      @currentPath = @rootPath

  createTable: (routes) -> routes.call @

  getIndexedTable: -> _.indexBy @table, 'name'

  getAction: (id) ->
    pair = id.split '#'

    if pair.length == 1
      [(@options.controller ? 'application'), id]
    else
      pair

  root: (name) ->
    [controller, action] = @getAction name

    @table.push
      path: Leaf.Utils.regulateUrl @rootPath
      controller: controller
      action: action
      name: 'root'

  get: (name, options = {}) ->
    [controller, action] = @getAction options.to ? name
    path = options.path ? @currentPath

    @table.push
      path: Leaf.Utils.regulateUrl "#{path}/#{name}"
      controller: controller
      action: action
      name: "#{controller}_#{action}"

  resources: (args...) ->
    argc = args.length

    [controller, options, sub] =
      if argc == 1
        [args[0], {}, null]
      else if argc == 2 && _.isObject(args[1])
        [args[0], args[1], null]
      else if argc == 2 && _.isFunction(args[1])
        [args[0], {}, args[1]]
      else if argc == 3
        args

    options.controller = controller

    if sub
      op = $.extend {}, options, { path: "#{@rootPath}/#{controller}" }
      r = new Leaf.Router @config, @table, op
      sub.call r

    f = Leaf.Utils.filter options

    @collection 'index', options if f.index
    @member 'show', options if f.show
    @member 'edit', options if f.edit

  collection: (name, options = @options) ->
    if _.isFunction name
      name.call {
        get: (args...) => @collection args...
      }
    else
      path = "#{@rootPath}/#{options.controller}"
      def =
        controller: options.controller
        action: name

      if 'index' == name
        def.path = Leaf.Utils.regulateUrl path
        def.name = options.controller
      else
        def.path = Leaf.Utils.regulateUrl "#{path}/#{name}"
        def.name = "#{name}_#{options.controller}"

      @table.push def

  member: (name, options = @options) ->
    model = _.singularize options.controller
    id = options.id ? ":#{model}_id"
    path = "#{@rootPath}/#{options.controller}/#{id}"

    if _.isFunction name
      name.call {
        get: (args...) => @member args...
      }
    else
      def =
        controller: options.controller
        action: name

      if 'show' == name
        def.path = Leaf.Utils.regulateUrl path
        def.name = model
      else
        def.path = Leaf.Utils.regulateUrl "#{path}/#{name}"
        def.name = "#{name}_#{model}"

      @table.push def

