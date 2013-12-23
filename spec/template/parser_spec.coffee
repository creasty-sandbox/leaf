
describe 'Leaf.Template.Parser', ->

  it 'should be defined', ->
    expect(Leaf.Template.Parser).toBeDefined()

  it 'should create instance', ->
    pr = new Leaf.Template.Parser()
    expect(pr).not.toBeNull()
    expect(pr.constructor).toBe Leaf.Template.Parser


describe 'parser', ->

  DUMMY_BUFFER = 'buffer'
  psr = null

  beforeEach ->
    psr = new Leaf.Template.Parser()


  describe '#init(buffer)', ->

    it 'should throw an exception if `buffer` is not given', ->
      ctx = -> psr.init()
      expect(ctx).toThrow()

    it 'should have root and parents stack with initialization', ->
      psr.init DUMMY_BUFFER
      expect(psr.root).toBeDefined()
      expect(psr.parents).toBeDefined()
      expect(psr.parents[0]).toBe psr.root


  describe '#parseExpression(node, expr)', ->

    it 'should return top level variables', ->
      psr.init DUMMY_BUFFER

      expr = 'foo.bar.baz'

      node = psr.parseExpression expr

      expect(node.vars).toHaveContents ['foo']

    it 'should ignore JavaScript\'s keywords and reserved words', ->
      psr.init DUMMY_BUFFER

      expr = 'window.location.href + document.title'

      node = psr.parseExpression expr

      expect(node.vars.length).toBe 0

    it 'should ignore variables starting with a capital letter', ->
      psr.init DUMMY_BUFFER

      expr = 'new Date() + OFFSET'

      node = psr.parseExpression expr

      expect(node.vars.length).toBe 0

    it 'should ignore variables starting with underscore', ->
      psr.init DUMMY_BUFFER

      expr = '_tmp_var'

      node = psr.parseExpression expr

      expect(node.vars.length).toBe 0

    it 'should handle property accessor with brackets', ->
      psr.init DUMMY_BUFFER

      expr = 'foo.bar[xx.yy].baz'

      node = psr.parseExpression expr

      expect(node.vars).toHaveContents ['foo', 'xx']

    it 'should handle function call', ->
      psr.init DUMMY_BUFFER

      expr = 'foo.bar(xx.yy).baz'

      node = psr.parseExpression expr

      expect(node.vars).toHaveContents ['foo', 'xx']

    it 'should omit hash key literals', ->
      psr.init DUMMY_BUFFER

      expr = '{ key1: val1, key2: val2.val21 }'

      node = psr.parseExpression expr

      expect(node.vars).toHaveContents ['val1', 'val2']

    it 'should omit string literals', ->
      psr.init DUMMY_BUFFER

      e1 = 'foo + "this string"'

      n1 = psr.parseExpression e1

      expect(n1.vars).toHaveContents ['foo']

      e2 = "foo + 'this string'"

      n2 = psr.parseExpression e2

      expect(n2.vars).toHaveContents ['foo']

    it 'should omit string literals with escaped quotes', ->
      psr.init DUMMY_BUFFER

      expr = 'foo + "this \\"st\'ring" + bar + \'this "is \\\' string\''

      node = psr.parseExpression expr

      expect(node.vars).toHaveContents ['foo', 'bar']

    it 'should omit regexp literals', ->
      psr.init DUMMY_BUFFER

      expr = '/\\d+\\/\\d+/.exec(foo)'

      node = psr.parseExpression expr

      expect(node.vars).toHaveContents ['foo']


  describe '#parseTagAttrs(node, attrs)', ->

    it 'should create empty hash when `attrs` has no vaild definitions of attribute', ->
      psr.init DUMMY_BUFFER

      node = {}
      psr.parseTagAttrs node, '', ''

      expect(node.attrs).toBeDefined()
      expect(Object.keys(node.attrs).length).toBe 0

    it 'should create hash object for each attributes, bindings and actions', ->
      psr.init DUMMY_BUFFER

      node = {}
      psr.parseTagAttrs node, 'id="foo" $class="bar" $my="baz" @click="alert"', ''

      token =
        attrs: { 'id': 'foo' }
        attrBindings:
          'class': { expr: 'bar', vars: ['bar'] }
        localeBindings:
          'my': { expr: 'baz', vars: ['baz'] }
        actions:
          'click': 'alert'

      expect(node).toHaveContents token

    it 'should treat attr as a locale binding if its name is not vaild for tag', ->
      psr.init DUMMY_BUFFER

      n1 = name: 'a'
      psr.parseTagAttrs n1, '$href="link"'

      expect(n1.attrBindings).toBeDefined()
      expect(n1.attrBindings.href).toBeDefined()

      n2 = name: 'div'
      psr.parseTagAttrs n2, '$href="link"'

      expect(n2.localeBindings).toBeDefined()
      expect(n2.localeBindings.href).toBeDefined()


  describe '#parseNode(parents, token)', ->

    it 'should should append text nodes to their parent', ->
      psr.init DUMMY_BUFFER

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
      psr.init DUMMY_BUFFER

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
        value:
          expr: 'interpolation'
          vars: ['interpolation']
        escape: true

      expect(psr.root.contents.length).toBe 1
      expect(psr.root.contents[0]).toHaveContents node

    it 'should should append self-closing tag nodes to their parent', ->
      psr.init DUMMY_BUFFER

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
      psr.init DUMMY_BUFFER

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
        psr.init DUMMY_BUFFER

        token =
          type: T_TAG_CLOSE
          buffer: '</div>'
          name: 'div'
          index: 0
          length: 6

        psr.parseNode psr.parents, token

      expect(ctx).toThrow()

    it 'should close current parent and set current parent to self when closing tags appear', ->
      psr.init DUMMY_BUFFER

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
      psr.init buffer
      psr.parseTree psr.parents

      result = [
        {
          type: T_TAG_OPEN
          context: {}
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
      psr.init buffer
      psr.parseTree psr.parents

      result = [
        {
          type: T_TAG_OPEN
          context: {}
          name: 'section'
          attrs: {}
          attrBindings: {}
          localeBindings: {}
          actions: {}
          scope: {}
          contents: [
            {
              type: T_TAG_OPEN
              contents: []
              context: {}
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
      psr.init buffer
      psr.parseTree psr.parents

      result = [
        {
          type: T_TAG_OPEN
          context: {}
          name: 'div'
          attrs: {}
          attrBindings: {}
          localeBindings:
            'var1': { expr: 'foo.var1', vars: ['foo'] }
          actions: {}
          scope:
            'var1': { expr: 'foo.var1', vars: ['foo'] }
          contents: [
            {
              type: T_TAG_OPEN
              contents: []
              context: {}
              name: 'div'
              attrs: {}
              attrBindings: {}
              localeBindings:
                'var2': { expr: 'foo.var2', vars: ['foo'] }
              actions: {}
              scope:
                'var1': { expr: 'foo.var1', vars: ['foo'] }
                'var2': { expr: 'foo.var2', vars: ['foo'] }
            }
          ]
        }
      ]

      expect(psr.root.contents).toHaveContents result


