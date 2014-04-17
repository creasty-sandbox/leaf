
describe 'new Leaf.View()', ->

  class TestView extends Leaf.View

    elements:
      'container':   '#test_container'
      '@container2': 'body $container'
      'inner':       '$container > .inner'
      'inner2':      '$inner > .inner2'
      'btn':         '$container > .btn'

    events:
      'btn click': 'btnClick'

    setup: ->
      @test = {}

    btnClick: ->
      @test.btnClick = true


  beforeEach ->
    @$el = $ '''
      <div>
        <div id="test_container" data-ck="1">
          <div class="inner" data-ck="2">
            <div class="inner2" data-ck="3"></div>
          </div>
          <div class="btn" data-ck="4"></div>
        </div>
      </div>
    '''
    @$el.appendTo $ 'body'

    @view = new TestView element: @$el

  afterEach ->
    @view.destroy()


  it 'should call `#setup` on initialization', ->
    expect(@view.test).toBeDefined()


  describe 'elements: {}', ->

    it 'should create variables of elements', ->
      expect(@view.$container.data 'ck').toEqual 1
      expect(@view.$container2.data 'ck').toEqual 1
      expect(@view.$inner.data 'ck').toEqual 2
      expect(@view.$inner2.data 'ck').toEqual 3
      expect(@view.$btn.data 'ck').toEqual 4


  describe 'events: {}', ->

    it 'should register an event handler to the element', ->
      @view.$btn.trigger 'click'
      expect(@view.test.btnClick).toBe true


