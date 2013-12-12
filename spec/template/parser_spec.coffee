
describe 'Leaf.Template.Parser', ->

  it 'should be defined', ->
    expect(Leaf.Template.Parser).toBeDefined()

  it 'should create instance', ->
    pr = new Leaf.Template.Parser()
    expect(pr).not.toBeNull()
    expect(pr.constructor).toBe Leaf.Template.Parser


describe 'parser', ->

  describe '#parseTagAttrs(t, attrs, tag)', ->

    it 'should create empty hash when `attrs` has no vaild definitions of attribute', ->
      tk = new Leaf.Template.Parser()

      t = {}
      tk.parseTagAttrs t, '', ''

      expect(t.attrs).toBeDefined()
      expect(Object.keys(t.attrs).length).toBe 0

    it 'should create hash object for each attributes, bindings and actions', ->
      tk = new Leaf.Template.Parser()

      t = {}
      tk.parseTagAttrs t, 'id="foo" $class="bar" $my="baz" @click="alert"', ''
      token =
        attrs: { 'id': 'foo' }
        attrBindings: { 'class': 'bar' }
        localeBindings: { 'my': 'baz' }
        actions: { 'click': 'alert' }

      expect(t).toHaveContents token

    it 'should treat attr as a locale binding if its name is not vaild for tag', ->
      tk = new Leaf.Template.Parser()

      t1 = {}
      tk.parseTagAttrs t1, '$href="link"', 'a'

      expect(t1.attrBindings).toBeDefined()
      expect(t1.attrBindings.href).toBe 'link'

      t2 = {}
      tk.parseTagAttrs t2, '$href="link"', 'div'

      expect(t2.localeBindings).toBeDefined()
      expect(t2.localeBindings.href).toBe 'link'


