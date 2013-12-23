
describe 'Leaf.Component', ->

  it 'should be defined', ->
    expect(Leaf.Component).toBeDefined()


  describe '::register(name, node)', ->

    it 'should be defined', ->
      expect(Leaf.Component.register).toBeDefined()

    it 'should register `node` as componet by the name of `name`', ->
      # TODO
      expect(false).toBe true


  describe '::get(name)', ->

    it 'should be defined', ->
      expect(Leaf.Component.get).toBeDefined()

    it 'should return a node of the defined component', ->
      # TODO
      expect(false).toBe true


describe 'Component views', ->

  createDOM = (obj, buffer) ->
    psr = new Leaf.Template.Parser()
    psr.init buffer

    gen = new Leaf.Template.DOMGenerator()
    gen.init psr.getTree(), obj
    gen.getDOM()


  describe '<component name="foo">', ->

    it 'should throw an exception when name attribute is not set', ->
      # TODO
      expect(false).toBe true


  describe '<foo>', ->

    it 'should throw an exception if component is not defined', ->
      # TODO
      expect(false).toBe true


