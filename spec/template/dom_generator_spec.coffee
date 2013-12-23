
describe 'Leaf.Template.DOMGenerator', ->

  it 'should be defined', ->
    expect(Leaf.Template.DOMGenerator).toBeDefined()

  it 'should create instance', ->
    gen = new Leaf.Template.DOMGenerator()
    expect(gen).not.toBeNull()
    expect(gen.constructor).toBe Leaf.Template.DOMGenerator


describe 'domGenerator', ->

  DUMMY_TREE = []
  DUMMY_OBJ = {}

  beforeEach ->
    @obj = new Leaf.Observable
      id: 1
      name: 'John'
      age: 27

    @gen = new Leaf.Template.DOMGenerator()


  describe '#init(tree, obj)', ->

    it 'should throw an exception if neither `tree` nor `obj` are given', ->
      ctx = ->
        @gen.init()

      expect(ctx).toThrow()

    it 'should create new parent node', ->
      @gen.init DUMMY_TREE, DUMMY_OBJ
      expect(@gen.$parent).toBeDefined()


  describe '#bind({ expr, vars })', ->

    beforeEach ->
      @gen.init DUMMY_TREE, @obj

    it 'should return a binder function', ->
      binder = @gen.bind expr: 'name.toUpperCase()', vars: ['name']

      expect(typeof binder).toBe 'function'

    it 'should evaluate an expression with values of the object and call a routine function with a result', ->
      binder = @gen.bind expr: 'name.toUpperCase()', vars: ['name']

      res = null

      binder (result) -> res = result

      expect(res).toBe 'JOHN'

    it 'should re-evaluate expression and call a routine function when dependents value of the object are updated', ->
      binder = @gen.bind expr: 'name.toUpperCase()', vars: ['name']

      res = null

      binder (result) -> res = result

      @obj.set 'name', 'David'

      expect(res).toBe 'DAVID'


  describe '#bindAttributes($el, attrs)', ->

    beforeEach ->
      @gen.init DUMMY_TREE, @obj

      @$el = $ '<div/>'

      @attrs =
        id: { expr: "'user_' + id", vars: ['id'] }


    it 'should set attributes to an element', ->
      @gen.bindAttributes @$el, @attrs

      expect(@$el).toHaveAttr 'id', 'user_1'

    it 'should update a value of attribute when the object value is changed', ->
      @gen.bindAttributes @$el, @attrs

      @obj.set 'id', 2

      expect(@$el).toHaveAttr 'id', 'user_2'


  describe '#bindLocales($el, attrs)', ->

    # spec not fixed


  describe '#registerActions($el, actions)', ->

    it 'should register view action to user action', ->
      @gen.init DUMMY_TREE, DUMMY_OBJ

      $el = $ '<div/>'

      isClicked = false
      $el.on 'myClickEvent', -> isClicked = true

      actions = click: 'myClickEvent'

      @gen.registerActions $el, actions

      $el.trigger 'click'

      expect(isClicked).toBe true


  describe '#createElement(node, $parent)', ->

    it 'should append an element node to `$parent`', ->
      @gen.init DUMMY_TREE, DUMMY_OBJ

      $parent = $ '<div/>'
      node =
        type: T_TAG_OPEN
        name: 'span'
        attrs: 'class': 'foo'
        attrBindings: {}
        localeBindings: {}
        actions: {}
        contents: []

      @gen.createElement node, $parent

      expect($parent).toHaveHtml '<span class="foo"></span>'


  describe '#createTextNode(node, $parent)', ->

    it 'should append a text node to `$parent`', ->
      @gen.init DUMMY_TREE, DUMMY_OBJ

      $parent = $ '<div/>'
      node = buffer: 'code is poetry'
      @gen.createTextNode node, $parent

      expect($parent).toHaveText node.buffer


  describe '#createInterpolationNode(node, $parent)', ->

    beforeEach ->
      @gen.init DUMMY_TREE, @obj
      @$parent = $ '<div/>'


    it 'should append a text node with escaped-interpolation', ->
      node =
        value: { expr: 'name.toUpperCase()', vars: ['name'] }
        escape: true

      @gen.createInterpolationNode node, @$parent

      expect(@$parent).toHaveText 'JOHN'

    it 'should append parsed html with unescaped-interpolation', ->
      node =
        value: { expr: "'<b>' + name.toUpperCase() + '</b>'", vars: ['name'] }
        escape: false

      @gen.createInterpolationNode node, @$parent

      expect(@$parent).toHaveHtml '<b>JOHN</b>'

    it 'should update the value of text node when the object value is changed', ->
      node =
        value: { expr: 'name.toUpperCase()', vars: ['name'] }
        escape: true

      @gen.createInterpolationNode node, @$parent

      @obj.set 'name', 'David'

      expect(@$parent).toHaveText 'DAVID'

    it 'should update html when the object value is changed', ->
      node =
        value: { expr: "'<b>' + name.toUpperCase() + '</b>'", vars: ['name'] }
        escape: false

      @gen.createInterpolationNode node, @$parent

      @obj.set 'name', 'David'

      expect(@$parent).toHaveHtml '<b>DAVID</b>'

