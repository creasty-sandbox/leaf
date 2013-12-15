
###

buffer = '<p>{{ name.toUpperCase() + 234 }}</p>'
psr = new Leaf.Template.Parser buffer
tree = psr.getTree()

obj = new Leaf.Observable name: 'John'

dom = new Leaf.Template.View tree, obj
dom.getView()

###

describe 'Leaf.Template.View', ->

  it 'should be defined', ->
    expect(Leaf.Template.View).toBeDefined()

  it 'should create instance', ->
    pr = new Leaf.Template.View()
    expect(pr).not.toBeNull()
    expect(pr.constructor).toBe Leaf.Template.View


describe 'view', ->

  DUMMY_TREE = []
  DUMMY_OBJ = {}

  view = null
  obj = null


  beforeEach ->
    obj = new Leaf.Observable
      id: 1
      name: 'John'
      age: 27

    view = new Leaf.Template.View()


  describe '#init(tree, obj)', ->

    it 'should throw an exception if neither `tree` nor `obj` are given', ->
      ctx = ->
        view.init()

      expect(ctx).toThrow()

    it 'should create new parent node', ->
      view.init DUMMY_TREE, DUMMY_OBJ
      expect(view.$parent).toBeDefined()


  describe '#bind({ expr, vars })', ->

    beforeEach ->
      view.init DUMMY_TREE, obj

    it 'should return a binder function', ->
      binder = view.bind expr: 'name.toUpperCase()', vars: ['name']

      expect(typeof binder).toBe 'function'

    it 'should evaluate an expression with values of the object and call a routine function with a result', ->
      binder = view.bind expr: 'name.toUpperCase()', vars: ['name']

      res = null

      binder (result) -> res = result

      expect(res).toBe 'JOHN'

    it 'should re-evaluate expression and call a routine function when dependents value of the object are updated', ->
      binder = view.bind expr: 'name.toUpperCase()', vars: ['name']

      res = null

      binder (result) -> res = result

      obj.set 'name', 'David'

      expect(res).toBe 'DAVID'


  describe '#bindAttributes($el, attrs)', ->

    $el = null
    attrs = null

    beforeEach ->
      view.init DUMMY_TREE, obj

      $el = $ '<div/>'

      attrs =
        id: { expr: "'user_' + id", vars: ['id'] }


    it 'should set attributes to an element', ->
      view.bindAttributes $el, attrs

      expect($el).toHaveAttr 'id', 'user_1'

    it 'should update a value of attribute when the object value is change', ->
      view.bindAttributes $el, attrs

      obj.set 'id', 2

      expect($el).toHaveAttr 'id', 'user_2'


  describe '#bindLocales($el, attrs)', ->

    # spec not fixed


  describe '#registerActions($el, actions)', ->

    # TODO


  describe '#createElement(node, $parent)', ->

    # TODO


  describe '#createTextNode(node, $parent)', ->

    # TODO


  describe '#createInterpolationNode(node, $parent)', ->

    # TODO


