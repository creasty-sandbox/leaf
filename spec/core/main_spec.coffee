
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

#=== Event
#==============================================================================================
describe 'Leaf.Event', ->

  beforeEach ->
    @localObj = {}
    @e = new Leaf.Event @localObj

  it '#on で handler を登録する', ->
    called = []

    @e.on 'test', -> called.push 1
    @e.on 'test', -> called.push 2
    @e.trigger 'test'

    expect(called).toEqual [1, 2]

  it '#off で handler を unsubscribe する', ->
    called = []

    @e.on 'test', -> called.push 1

    handler = -> called.push 2
    @e.on 'test', handler
    @e.off 'test', handler

    @e.trigger 'test'

    expect(called).toEqual [1]

  it '#one で一度しか実行しない handler を登録する', ->
    called = 0

    @e.one 'test', -> ++called

    @e.trigger 'test' for i in [0...3]

    expect(called).toEqual 1

  it '同一のオブジェクトでは handler が購読情報が共有される', ->
    e1 = new Leaf.Event @localObj
    e2 = new Leaf.Event @localObj

    called = []

    e1.on 'test', -> called.push 'e1'
    e2.on 'test', -> called.push 'e2'

    @e.trigger 'test'

    expect(called).toEqual ['e1', 'e2']


#=== Inflector
#==============================================================================================
describe 'Leaf.Inflector', ->

  it '#singularize で単語を単数形にする', ->
    expect(Leaf.Inflector.singularize 'studies').toEqual 'study'

  it '#pluralize で単語を複数形にする', ->
    expect(Leaf.Inflector.pluralize 'person').toEqual 'people'

  it '数値に応じて複数形にする', ->
    expect(Leaf.Inflector.pluralize 'person', 0).toEqual 'people'
    expect(Leaf.Inflector.pluralize 'person', 1).toEqual 'person'


#=== View
#==============================================================================================
describe 'Leaf.View', ->

  # View
  class window.TestView extends Leaf.View

    elements:
      'container':  '#test_container'
      'container2': 'body $container'
      'inner':      '$container > .inner'
      'inner2':     '$inner > .inner2'
      'btn':        '$container > .btn'

    events:
      'btn click': 'btnClick'

    setup: ->
      @test = {}

    btnClick: ->
      @test.btnClick = true

  $test = null

  beforeEach ->
    unless $test
      $test = $ """
        <div id="test_container" data-ck="1">
          <div class="inner" data-ck="2">
            <div class="inner2" data-ck="3"></div>
          </div>
          <div class="btn" data-ck="4"></div>
        </div>
      """
      $test.appendTo $ 'body'

    @view = new TestView()

  afterEach ->
    @view.destroy()

  it 'elements で必要な要素を名前を付けて定義する', ->
    expect(@view.$container.data 'ck').toEqual 1
    expect(@view.$container2.data 'ck').toEqual 1
    expect(@view.$inner.data 'ck').toEqual 2
    expect(@view.$inner2.data 'ck').toEqual 3
    expect(@view.$btn.data 'ck').toEqual 4

  it 'setup で初期化処理をする', ->
    expect(@view.test).toBeDefined()

  it 'events で event を定義する', ->
    @view.$btn.trigger 'click'
    expect(@view.test.btnClick).toBe true


