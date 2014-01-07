
###
describe '@root', ->

  router = null

  beforeEach ->
    config = basePath: '/'
    router = new Cinder.Router config

  it 'creates the root path', ->
    router.createTable ->
      @root 'pages#index'

    table = router.getIndexedTable()

    # Expects
    expect(table.root).toBeDefined()
    expect(table.root.path).toEqual '/'
    expect(table.root.controller).toEqual 'pages'
    expect(table.root.action).toEqual 'index'

  it 'change the index to the root inside `@resources`', ->
    router.createTable ->
      @resources 'pages', ->
        @root 'all'

    table = router.getIndexedTable()

    # Expects
    expect(table.pages_root).toBeDefined()
    expect(table.pages_root.path).toEqual '/pages'
    expect(table.pages_root.controller).toEqual 'pages'
    expect(table.pages_root.action).toEqual 'all'
###

