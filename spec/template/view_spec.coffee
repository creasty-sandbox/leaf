
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
  DUMMT_OBJ = {}
  view = null

  beforeEach ->
    view = new Leaf.Template.View()


  describe '#init(tree, obj)', ->

    it 'should throw an exception if neither `tree` nor `obj` are given', ->
      ctx = ->
        view.init()

      expect(ctx).toThrow()

    it 'should create new parent node', ->
      view.init DUMMY_TREE, DUMMT_OBJ
      expect(view.$parent).toBeDefined()



