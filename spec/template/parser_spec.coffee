
describe 'new Leaf.Template.Parser(buffer)', ->

  DUMMY_BUFFER = 'buffer'

  withoutNodeId = (o) ->
    if _.isArray o
      omitted = []
      omitted.push withoutNodeId(val) for val in o
    else if _.isPlainObject o
      omitted = {}

      for key, val of o when '_nodeID' != key
        omitted[key] =
          if _.isPlainObject(val) || _.isArray(val)
            withoutNodeId val
          else
            val
    else
      omitted = o

    omitted


  it 'should throw an exception if `buffer` is not given', ->
    ctx = => new Leaf.Template.Parser()
    expect(ctx).toThrow()

  it 'should have root and parents stack with initialization', ->
    psr = new Leaf.Template.Parser DUMMY_BUFFER
    expect(psr.root).toBeDefined()
    expect(psr.parents).toBeDefined()
    expect(psr.parents[0]).toBe psr.root


  describe '#parseTagAttrs(node, attrs)', ->

    beforeEach ->
      @psr = new Leaf.Template.Parser DUMMY_BUFFER


    it 'should create empty hash when `attrs` has no vaild definitions of attribute', ->
      node = {}
      @psr.parseTagAttrs node, '', ''

      expect(node.attrs).toBeDefined()
      expect(Object.keys(node.attrs).length).toBe 0

    it 'should create hash object for each attributes, bindings and actions', ->
      node = {}
      @psr.parseTagAttrs node, 'id="foo" class="bar-{{bar}}" $my="baz" @click="alert"', ''

      token =
        attrs:
          'id': 'foo'
        attrBindings:
          'class': 'bar-{{bar}}'
        localeBindings:
          'my': 'baz'
        actions:
          'click': 'alert'

      expect(node).toHaveContents token


  describe '#parseNode(parents, token)', ->

    beforeEach ->
      @psr = new Leaf.Template.Parser DUMMY_BUFFER


    it 'should should append text nodes to their parent', ->
      token =
        type: T_TEXT
        buffer: 'this will be a text'
        index: 0
        length: 19

      @psr.parseNode @psr.parents, token

      node =
        type: T_TEXT
        buffer: 'this will be a text'
        empty: false

      expect(@psr.root.contents.length).toBe 1
      expect(withoutNodeId(@psr.root.contents[0])).toHaveContents node

    it 'should should append interpolation nodes to their parent', ->
      token =
        type: T_INTERPOLATION
        buffer: '{{ interpolation }}'
        index: 0
        length: 19
        textBinding:
          val: 'interpolation'
          escape: true

      @psr.parseNode @psr.parents, token

      node =
        type: T_INTERPOLATION
        value: 'interpolation'
        escape: true

      expect(@psr.root.contents.length).toBe 1
      expect(@psr.root.contents[0]).toHaveContents node

    it 'should should append self-closing tag nodes to their parent', ->
      token =
        type: T_TAG
        closing: false
        selfClosing: false
        buffer: '<img src="sample.gif">'
        attrPart: ' src="sample.gif"'
        name: 'img'
        index: 0
        length: 22

      @psr.parseNode @psr.parents, token

      node =
        type: T_TAG
        customTag: false
        selfClosing: true
        contents: []
        context: {}
        name: 'img'
        attrs: { 'src': 'sample.gif' }
        attrBindings: {}
        localeBindings: {}
        actions: {}

      expect(@psr.root.contents.length).toBe 1
      expect(withoutNodeId(@psr.root.contents[0])).toHaveContents node

    it 'should append opening tag nodes to their parent and set current parent to self', ->
      token =
        type: T_TAG
        closing: false
        selfClosing: false
        buffer: '<div>'
        attrPart: ''
        name: 'div'
        index: 0
        length: 5

      @psr.parseNode @psr.parents, token

      node =
        type: T_TAG
        customTag: false
        selfClosing: false
        contents: []
        context: {}
        name: 'div'
        attrs: {}
        attrBindings: {}
        localeBindings: {}
        actions: {}

      expect(@psr.root.contents.length).toBe 1
      expect(withoutNodeId(@psr.root.contents[0])).toHaveContents node
      expect(@psr.parents[0]).toBe @psr.root.contents[0]

    it 'should throw an exception when attempt to close tag which has not been open', ->
      ctx = =>
        @psr.init DUMMY_BUFFER

        token =
          type: T_TAG
          closing: true
          selfClosing: false
          buffer: '</div>'
          name: 'div'
          index: 0
          length: 6

        @psr.parseNode @psr.parents, token

      expect(ctx).toThrow()

    it 'should close current parent and set current parent to self when closing tags appear', ->
      tokenOpen =
        type: T_TAG
        closing: false
        selfClosing: false
        buffer: '<div>'
        attrPart: ''
        name: 'div'
        index: 0
        length: 5

      node =
        type: T_TAG
        selfClosing: false
        customTag: false
        contents: []
        context: {}
        name: 'div'
        attrs: {}
        attrBindings: {}
        localeBindings: {}
        actions: {}

      @psr.parseNode @psr.parents, tokenOpen

      tokenClose =
        type: T_TAG
        closing: true
        selfClosing: false
        buffer: '</div>'
        name: 'div'
        index: 0
        length: 6

      @psr.parseNode @psr.parents, tokenClose

      expect(@psr.root.contents.length).toBe 1
      expect(withoutNodeId(@psr.root.contents[0])).toHaveContents node
      expect(@psr.parents.length).toBe 1


  describe '#parseTree(parents)', ->

    it 'should return parse tree of basic DOM structure', ->
      psr = new Leaf.Template.Parser '<div>text</div>'
      psr.parseTree psr.parents

      result = [
        {
          type: T_TAG
          selfClosing: false
          customTag: false
          context: {}
          name: 'div'
          attrs: {}
          attrBindings: {}
          localeBindings: {}
          actions: {}
          contents: [
            {
              type: T_TEXT
              buffer: 'text'
              empty: false
            }
          ]
        }
      ]

      expect(withoutNodeId(psr.root.contents)).toHaveContents result

    it 'should return parse tree of nested tags', ->
      psr = new Leaf.Template.Parser '<section><div></div></section>'
      psr.parseTree psr.parents

      result = [
        {
          type: T_TAG
          selfClosing: false
          customTag: false
          context: {}
          name: 'section'
          attrs: {}
          attrBindings: {}
          localeBindings: {}
          actions: {}
          contents: [
            {
              type: T_TAG
              selfClosing: false
              customTag: false
              contents: []
              context: {}
              name: 'div'
              attrs: {}
              attrBindings: {}
              localeBindings: {}
              actions: {}
            }
          ]
        }
      ]

      expect(withoutNodeId(psr.root.contents)).toHaveContents result

