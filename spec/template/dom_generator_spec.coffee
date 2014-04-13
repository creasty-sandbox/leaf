
describe 'new Leaf.Template.DOMGenerator(tree, obj, scope)', ->

  DUMMY_TREE = []
  DUMMY_OBJ = new Leaf.ObservableObject()

  beforeEach ->
    @obj = new Leaf.Observable
      id: 1
      name: 'John'
      age: 27


  it 'should throw an exception if neither `tree` nor `obj` are given', ->
    ctx = -> new Leaf.Template.DOMGenerator()

    expect(ctx).toThrow()

  it 'should create new parent node', ->
    gen = new Leaf.Template.DOMGenerator DUMMY_TREE, DUMMY_OBJ
    expect(gen.$parent).toBeDefined()


  describe '#bindAttributes($el, attrs)', ->

    beforeEach ->
      @gen = new Leaf.Template.DOMGenerator DUMMY_TREE, @obj

      @$el = $ '<div/>'

      @attrs =
        id: "'user_' + this.id"


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
      gen = new Leaf.Template.DOMGenerator DUMMY_TREE, DUMMY_OBJ

      $el = $ '<div/>'

      handler = jasmine.createSpy 'event handler'
      $el.on 'myClickEvent', handler

      actions = click: 'myClickEvent'

      gen.registerActions $el, actions

      $el.trigger 'click'

      expect(handler).toHaveBeenCalled()


  describe '#createElement(node, $parent)', ->

    it 'should append an element node to `$parent`', ->
      gen = new Leaf.Template.DOMGenerator DUMMY_TREE, DUMMY_OBJ

      $parent = $ '<div/>'
      node =
        type: T_TAG_OPEN
        name: 'span'
        attrs: 'class': 'foo'
        attrBindings: {}
        localeBindings: {}
        actions: {}
        contents: []

      gen.createElement node, $parent

      expect($parent).toHaveHtml '<span class="foo"></span>'


  describe '#createTextNode(node, $parent)', ->

    it 'should append a text node to `$parent`', ->
      gen = new Leaf.Template.DOMGenerator DUMMY_TREE, DUMMY_OBJ

      $parent = $ '<div/>'
      node = buffer: 'code is poetry'
      gen.createTextNode node, $parent

      expect($parent).toHaveText node.buffer


  describe '#createInterpolationNode(node, $parent)', ->

    beforeEach ->
      @gen = new Leaf.Template.DOMGenerator DUMMY_TREE, @obj
      @$parent = $ '<div/>'


    it 'should append a text node with escaped-interpolation', ->
      node =
        type: T_INTERPOLATION
        value: 'this.name.toUpperCase()'
        escape: true

      @gen.createInterpolationNode node, @$parent

      expect(@$parent).toHaveText 'JOHN'

    it 'should append parsed html with unescaped-interpolation', ->
      node =
        type: T_INTERPOLATION
        value: "'<b>' + this.name.toUpperCase() + '</b>'"
        escape: false

      @gen.createInterpolationNode node, @$parent

      html = @$parent.html()

      expect(!!~html.indexOf('<b>JOHN</b>')).toBe true

    it 'should update the value of text node when the object value is changed', ->
      node =
        type: T_INTERPOLATION
        value: 'this.name.toUpperCase()'
        escape: true

      @gen.createInterpolationNode node, @$parent

      @obj.set 'name', 'David'

      expect(@$parent).toHaveText 'DAVID'

    it 'should update html when the object value is changed', ->
      node =
        type: T_INTERPOLATION
        value: "'<b>' + this.name.toUpperCase() + '</b>'"
        escape: false

      @gen.createInterpolationNode node, @$parent

      @obj.set 'name', 'David'

      html = @$parent.html()

      expect(!!~html.indexOf('<b>DAVID</b>')).toBe true

