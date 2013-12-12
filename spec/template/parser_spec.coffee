
describe 'Leaf.Template.Parser(buffer)', ->

  it 'should be defined', ->
    expect(Leaf.Template.Parser).toBeDefined()

  it 'should throw an exception if `buffer` is not given or is empty', ->
    ctx = ->
      psr = new Leaf.Template.Parser()

    expect(ctx).toThrow()

  it 'should create instance with buffer', ->
    pr = new Leaf.Template.Parser 'foo'
    expect(pr).not.toBeNull()
    expect(pr.constructor).toBe Leaf.Template.Parser


describe 'parser', ->

  it 'should have root and parents stack', ->
    psr = new Leaf.Template.Parser 'foo'
    expect(psr.root).toBeDefined()
    expect(psr.parents).toBeDefined()
    expect(psr.parents[0]).toBe psr.root


  describe '#parseTagAttrs(node, attrs)', ->

    it 'should create empty hash when `attrs` has no vaild definitions of attribute', ->
      tk = new Leaf.Template.Parser 'foo'

      t = {}
      tk.parseTagAttrs t, '', ''

      expect(t.attrs).toBeDefined()
      expect(Object.keys(t.attrs).length).toBe 0

    it 'should create hash object for each attributes, bindings and actions', ->
      tk = new Leaf.Template.Parser 'foo'

      t = {}
      tk.parseTagAttrs t, 'id="foo" $class="bar" $my="baz" @click="alert"', ''
      token =
        attrs: { 'id': 'foo' }
        attrBindings: { 'class': 'bar' }
        localeBindings: { 'my': 'baz' }
        actions: { 'click': 'alert' }

      expect(t).toHaveContents token

    it 'should treat attr as a locale binding if its name is not vaild for tag', ->
      tk = new Leaf.Template.Parser 'foo'

      t1 = name: 'a'
      tk.parseTagAttrs t1, '$href="link"'

      expect(t1.attrBindings).toBeDefined()
      expect(t1.attrBindings.href).toBe 'link'

      t2 = name: 'div'
      tk.parseTagAttrs t2, '$href="link"'

      expect(t2.localeBindings).toBeDefined()
      expect(t2.localeBindings.href).toBe 'link'


  describe '#parseNode(parents, token)', ->

    it 'should should append text nodes to their parent', ->
      psr = new Leaf.Template.Parser 'foo'

      token =
        type: T_TEXT
        buffer: 'this will be a text'
        index: 0
        length: 19

      psr.parseNode psr.parents, token

      node =
        type: T_TEXT
        buffer: 'this will be a text'

      expect(psr.root.contents.length).toBe 1
      expect(psr.root.contents[0]).toHaveContents node

    it 'should should append interpolation nodes to their parent', ->
      psr = new Leaf.Template.Parser 'foo'

      token =
        type: T_INTERPOLATION
        buffer: '{{ interpolation }}'
        index: 0
        length: 19
        textBinding:
          val: 'interpolation'
          escape: true

      psr.parseNode psr.parents, token

      node =
        type: T_INTERPOLATION
        val: 'interpolation'
        escape: true

      expect(psr.root.contents.length).toBe 1
      expect(psr.root.contents[0]).toHaveContents node

    it 'should should append self-closing tag nodes to their parent', ->
      psr = new Leaf.Template.Parser 'foo'

      token =
        type: T_TAG_SELF
        buffer: '<img src="sample.gif">'
        attrPart: ' src="sample.gif"'
        name: 'img'
        index: 0
        length: 22

      psr.parseNode psr.parents, token

      node =
        type: T_TAG_SELF
        contents: []
        context: {}
        name: 'img'
        attrs: { 'src': 'sample.gif' }
        attrBindings: {}
        localeBindings: {}
        actions: {}
        scope: {}

      expect(psr.root.contents.length).toBe 1
      expect(psr.root.contents[0]).toHaveContents node

    it 'should should append opening tag nodes to their parent and set current parent to self', ->
      psr = new Leaf.Template.Parser 'foo'

      token =
        type: T_TAG_OPEN
        buffer: '<div>'
        attrPart: ''
        name: 'div'
        index: 0
        length: 5

      psr.parseNode psr.parents, token

      node =
        type: T_TAG_OPEN
        contents: []
        context: {}
        name: 'div'
        attrs: {}
        attrBindings: {}
        localeBindings: {}
        actions: {}
        scope: {}

      expect(psr.root.contents.length).toBe 1
      expect(psr.root.contents[0]).toHaveContents node
      expect(psr.parents[0]).toBe psr.root.contents[0]

    it 'should throw an exception when attempt to close tag which has not been open', ->
      ctx = ->
        psr = new Leaf.Template.Parser 'foo'

        token =
          type: T_TAG_CLOSE
          buffer: '</div>'
          name: 'div'
          index: 0
          length: 6

        psr.parseNode psr.parents, token

      expect(ctx).toThrow()

    it 'should close current parent and set current parent to self when closing tags appear', ->
      psr = new Leaf.Template.Parser 'foo'

      tokenOpen =
        type: T_TAG_OPEN
        buffer: '<div>'
        attrPart: ''
        name: 'div'
        index: 0
        length: 5

      node =
        type: T_TAG_OPEN
        contents: []
        context: {}
        name: 'div'
        attrs: {}
        attrBindings: {}
        localeBindings: {}
        actions: {}
        scope: {}

      psr.parseNode psr.parents, tokenOpen

      tokenClose =
        type: T_TAG_CLOSE
        buffer: '</div>'
        name: 'div'
        index: 0
        length: 6

      psr.parseNode psr.parents, tokenClose

      expect(psr.root.contents.length).toBe 1
      expect(psr.root.contents[0]).toHaveContents node
      expect(psr.parents.length).toBe 1


  describe '#parseTree(parents)', ->

    it 'should return parse tree of basic DOM structure', ->
      buffer = '<div>text</div>'
      psr = new Leaf.Template.Parser buffer
      psr.parseTree psr.parents

      result = [
        {
          type: T_TAG_OPEN
          context: { 'if': null }
          name: 'div'
          attrs: {}
          attrBindings: {}
          localeBindings: {}
          actions: {}
          scope: {}
          contents: [
            {
              type: T_TEXT
              buffer: 'text'
            }
          ]
        }
      ]

      expect(psr.root.contents).toHaveContents result

    it 'should return parse tree of nested tags', ->
      buffer = '<section><div></div></section>'
      psr = new Leaf.Template.Parser buffer
      psr.parseTree psr.parents

      result = [
        {
          type: 1
          context: { 'if': null }
          name: 'section'
          attrs: {}
          attrBindings: {}
          localeBindings: {}
          actions: {}
          scope: {}
          contents: [
            {
              type: 1
              contents: []
              context: { 'if': null }
              name: 'div'
              attrs: {}
              attrBindings: {}
              localeBindings: {}
              actions: {}
              scope: {}
            }
          ]
        }
      ]

      expect(psr.root.contents).toHaveContents result

    it 'should create a scope with locale bindings', ->
      buffer = '<div $var1="foo.var1"><div $var2="foo.var2"></div></div>'
      psr = new Leaf.Template.Parser buffer
      psr.parseTree psr.parents

      result = [
        {
          type: 1
          context: { 'if': null }
          name: 'div'
          attrs: {}
          attrBindings: {}
          localeBindings: { 'var1': 'foo.var1' }
          actions: {}
          scope: { 'var1': 'foo.var1' }
          contents: [
            {
              type: 1
              contents: []
              context: { 'if': null }
              name: 'div'
              attrs: {}
              attrBindings: {}
              localeBindings: { 'var2': 'foo.var2' }
              actions: {}
              scope: { 'var1': 'foo.var1', 'var2': 'foo.var2' }
            }
          ]
        }
      ]

      expect(psr.root.contents).toHaveContents result

