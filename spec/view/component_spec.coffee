
describe 'Leaf.Component', ->

  it 'should be defined', ->
    expect(Leaf.Component).toBeDefined()


  describe '::regulateName(name)', ->

    it 'should return empty string if `name` is falsy', ->
      expect(Leaf.Component.regulateName()).toBe ''

    it 'should dash-nize camelCase string', ->
      expect(Leaf.Component.regulateName('dashNize')).toBe 'dash-nize'

    it 'should strip invalid charactors', ->
      expect(Leaf.Component.regulateName('.name/')).toBe 'name'

    it 'should dense sequence of dashes and colons', ->
      expect(Leaf.Component.regulateName('foo--::-bar--baz-:')).toBe 'foo:bar-baz'


  describe '::register(name, node)', ->

    afterEach ->
      Leaf.Component.reset()


    it 'should be defined', ->
      expect(Leaf.Component.register).toBeDefined()

    it 'should register `node` as a component by the name of `name`', ->
      node = { contents: [] }

      Leaf.Component.register 'foo', node

      expect(Leaf.Component.components['foo']).toBeDefined()
      expect(Leaf.Component.components['foo']).toBe node.contents


  describe '::get(name)', ->

    afterEach ->
      Leaf.Component.reset()


    it 'should be defined', ->
      expect(Leaf.Component.get).toBeDefined()

    it 'should return undefined if the component is not defined', ->
      expect(Leaf.Component.get('zzz')).toBeUndefined()

    it 'should return a node of the defined component', ->
      node = { contents: [] }
      Leaf.Component.register 'foo', node
      expect(Leaf.Component.get('foo')).toBe node.contents



describe 'Component views', ->

  createDOM = (obj, buffer) ->
    psr = new Leaf.Template.Parser()
    psr.init buffer

    gen = new Leaf.Template.DOMGenerator()
    gen.init psr.getTree(), obj
    gen.getDOM()


  afterEach ->
    Leaf.Component.reset()


  describe '<component name="foo">', ->

    beforeEach ->
      @obj = new Leaf.ObservableObject()

    it 'should throw an exception when name attribute is not set', ->
      bufferWithError = '''
        <component></component>
      '''

      ctx = =>
        createDOM @obj, bufferWithError

      expect(ctx).toThrow()

    it 'should not create nodes on DOM', ->
      buffer = '''
        <component name="foo">this is componet foo</component>
      '''

      dom = createDOM @obj, buffer

      # expect(dom).toBeEmpty() # this will fail because of a marker node
      expect(dom).toHaveText ''

    it 'should define component by the name of name attribute', ->
      buffer = '''
        <component name="foo">this is componet foo</component>
      '''

      createDOM @obj, buffer

      expect(Leaf.Component.components['foo']).toBeDefined()


  describe '<component:foo>', ->

    beforeEach ->
      @obj = new Leaf.ObservableObject
        users: [
          { name: 'John' }
        ]


    it 'should throw an exception if component is not defined', ->
      buffer = '''
        <component:zzz>
      '''

      ctx = =>
        createDOM @obj, buffer

      expect(ctx).toThrow()

    it 'should append contents of a defined component', ->
      bufferDefComponent = '''
        <component name="foo">
          <div class="foo">
          </div>
        </component>
      '''

      createDOM @obj, bufferDefComponent

      buffer = '''
        <component:foo>
      '''

      dom = createDOM @obj, buffer

      expect(dom).toBe '.foo'

    it 'should be able to access to variables of locale bindings', ->
        bufferDefComponent = '''
          <component name="foo">
            {{ users[0].name }}
          </component>
        '''

        createDOM @obj, bufferDefComponent

        buffer = '''
          <component:foo $users="users">
        '''

        dom = createDOM @obj, buffer

        expect(dom).toHaveText 'John'

    it 'should be able to access to the value of locale bindings\' expression', ->
        bufferDefComponent = '''
          <component name="foo">
            {{ user.name }}
          </component>
        '''

        createDOM @obj, bufferDefComponent

        buffer = '''
          <component:foo $user="users[0]">
        '''

        dom = createDOM @obj, buffer

        expect(dom).toHaveText 'John'


