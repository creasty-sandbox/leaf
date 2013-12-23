
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

  describe '<component name="foo">', ->

    it 'should throw an exception when name attribute is not set', ->
      # TODO
      expect(false).toBe true


  describe '<foo>', ->

    it 'should throw an exception if component is not defined', ->
      # TODO
      expect(false).toBe true


