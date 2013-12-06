
describe 'Tokenizer', ->

  it 'should be defined', ->
    expect(Tokenizer).toBeDefined()

  it 'should create an instance', ->
    tk = new Tokenizer()
    expect(tk).not.toBeNull()
    expect(tk.constructor).toBe Tokenizer


describe 'tokenizer', ->

  describe '#eat', ->

    it 'should pop buffer by a length of token and return token', ->
      tk = new Tokenizer '1234$'

      expect(tk.buffer).toEqual '1234$'

      token = length: 4
      ate = tk.eat token

      expect(ate).toBe token
      expect(tk.buffer).toEqual '$'


  describe '#getText(buffer)', ->

    it 'should return T_NONE token when `buffer` is empty', ->
      tk = new Tokenizer()
      token = type: T_NONE
      expect(tk.getText('')).toHaveContents token

    it 'should return T_TEXT token when `buffer` is not empty', ->
      tk = new Tokenizer()

      buffer = 'text text'
      token =
        type: T_TEXT
        buffer: buffer
        index: 0
        length: buffer.length

      expect(tk.getText(buffer)).toHaveContents token


  describe '#getInterpolation(buffer)', ->

    it 'should return T_NONE token when there is no interpolations in `buffer`', ->
      tk = new Tokenizer()

      buffer = 'no interpolations in here'
      token = type: T_NONE

      expect(tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_INTERPOLATION token when `buffer` contains interpolations', ->
      tk = new Tokenizer()

      buffer = 'here goes an {{ interpolation }}'
      token =
        type: T_INTERPOLATION
        buffer: '{{ interpolation }}'
        index: 13
        length: 19
        textBinding:
          val: 'interpolation'
          escape: true

      expect(tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_INTERPOLATION token with no escape option for raw interpolations', ->
      tk = new Tokenizer()

      buffer = 'it is {{{ raw }}}'
      token =
        type: T_INTERPOLATION
        buffer: '{{{ raw }}}'
        index: 6
        length: 11
        textBinding:
          val: 'raw'
          escape: false

      expect(tk.getInterpolation(buffer)).toHaveContents token


  describe 'Tag tokens', ->

    describe '#tagAttrFragments(t, attrs, tag)', ->

      it 'should create empty hash when `attrs` has no vaild definitions of attribute', ->
        tk = new Tokenizer()

        t = {}
        tk.tagAttrFragments t, '', ''

        expect(t.attrs).toBeDefined()
        expect(Object.keys(t.attrs).length).toBe 0

      it 'should create hash object for each attributes, bindings and actions', ->
        tk = new Tokenizer()

        t = {}
        tk.tagAttrFragments t, 'id="foo" $class="bar" $my="baz" @click="alert"', ''
        token =
          attrs: { 'id': 'foo' }
          attrBindings: { 'class': 'bar' }
          localeBindings: { 'my': 'baz' }
          actions: { 'click': 'alert' }

        expect(t).toHaveContents token

      it 'should treat attr as a locale binding if its name is not vaild for tag', ->
        tk = new Tokenizer()

        t1 = {}
        tk.tagAttrFragments t1, '$href="link"', 'a'

        expect(t1.attrBindings).toBeDefined()
        expect(t1.attrBindings.href).toBe 'link'

        t2 = {}
        tk.tagAttrFragments t2, '$href="link"', 'div'

        expect(t2.localeBindings).toBeDefined()
        expect(t2.localeBindings.href).toBe 'link'


    describe '#getTag(buffer)', ->

      it 'should return T_NONE token when `buffer` is empty', ->
        tk = new Tokenizer()
        token = type: T_NONE
        expect(tk.getTag('')).toHaveContents token

      it 'should return T_TAG_OPEN token for opening tags', ->
        tk = new Tokenizer()

        buffer = 'text <div id="foo">'
        token =
          type: T_TAG_OPEN
          buffer: '<div id="foo">'
          name: 'div'
          attrs: { 'id': 'foo' }
          attrBindings: {}
          localeBindings: {}
          actions: {}
          index: 5
          length: 14

        expect(tk.getTag(buffer)).toHaveContents token

      it 'should return T_TAG_CLOSE token for closing tag', ->
        tk = new Tokenizer()

        buffer = 'text</div>'
        token =
          type: T_TAG_CLOSE
          buffer: '</div>'
          name: 'div'
          index: 4
          length: 6

        expect(tk.getTag(buffer)).toHaveContents token

      it 'should return T_TAG_SELF token for self closing tag', ->
        tk = new Tokenizer()

        buffer = 'text <img src="img.gif">'
        token =
          type: T_TAG_SELF
          buffer: '<img src="img.gif">'
          name: 'img'
          attrs: { 'src': 'img.gif' }
          attrBindings: {}
          localeBindings: {}
          actions: {}
          index: 5
          length: 19

        expect(tk.getTag(buffer)).toHaveContents token


  describe '#getToken', ->

    getTokenizer = (html) ->
      pf = new HtmlPreformatter html
      pf.minify()

      tokenizer = new Tokenizer pf.getHtml()
      tokenizer


    it 'should return T_NONE token when the buffer given is empty', ->
      tk = getTokenizer ''
      expect(tk.getToken()).toHaveContents { type: T_NONE }

    it 'should return tag element and text node tokens', ->
      html = """
        <div id="foo" class="bar">the quick <i>brown</i> fox <img src="img.gif"></div>
      """

      tokens = [
        {
          type: T_TAG_OPEN
          buffer: '<div id="foo" class="bar">'
          name: 'div'
          attrs: { 'id': 'foo', 'class': 'bar' }
          attrBindings: {}
          localeBindings: {}
          actions: {}
          index: 0
          length: 26
        }
        {
          type: T_TEXT
          buffer: 'the quick '
          index: 0
          length: 10
        }
        {
          type: T_TAG_OPEN
          buffer: '<i>'
          name: 'i'
          attrs: {}
          attrBindings: {}
          localeBindings: {}
          actions: {}
          index: 10
          length: 3
        }
        {
          type: T_TEXT
          buffer: 'brown'
          index: 0
          length: 5
        }
        {
          type: T_TAG_CLOSE
          buffer: '</i>'
          name: 'i'
          index: 5
          length: 4
        }
        {
          type: T_TEXT
          buffer: ' fox '
          index: 0
          length: 5
        }
        {
          type: T_TAG_SELF
          buffer: '<img src="img.gif">'
          name: 'img'
          attrs: { 'src': 'img.gif' }
          attrBindings: {}
          localeBindings: {}
          actions: {}
          index: 5
          length: 19
        }
        {
          type: T_TAG_CLOSE
          buffer: '</div>'
          name: 'div'
          index: 0
          length: 6
        }
      ]

      tk = getTokenizer html

      expect(tk.getToken()).toHaveContents token for token in tokens


    describe 'Data bindings', ->

      it 'should return tokens with data binding for normal attributes', ->
        html = """
          <img class="foo" $src="image.url">
        """
        token =
          type: T_TAG_SELF
          buffer: '<img class="foo" $src="image.url">'
          name: 'img'
          attrs: { 'class': 'foo' }
          attrBindings: { 'src': 'image.url' }
          localeBindings: {}
          actions: {}

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token


      it 'should return tokens with data binding of locales', ->
        html = """
          <div $model="model"></div>
        """

        token =
          type: T_TAG_OPEN
          buffer: '<div $model="model">'
          name: 'div'
          attrs: {}
          attrBindings: {}
          localeBindings: { 'model': 'model' }
          actions: {}

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token

      it 'should return tokens with data binding of text interpolations', ->
        html = """
          the quick brown {{ animal.name }} jumps
        """

        tokens = [
          {
            type: T_TEXT
            buffer: 'the quick brown '
            index: 0
            length: 16
          }
          {
            type: T_INTERPOLATION
            buffer: '{{ animal.name }}'
            textBinding: { val: 'animal.name', escape: true }
            index: 16
            length: 17
          }
          {
            type: T_TEXT
            buffer: ' jumps'
            index: 0
            length: 6
          }
        ]

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token for token in tokens


    describe 'Action handler', ->

      it 'should return token with action handler', ->
        html = '<input type="text" @focus="glow">'

        token =
          type: T_TAG_SELF
          buffer: '<input type="text" @focus="glow">'
          name: 'input'
          attrs: { 'type': 'text' }
          attrBindings: {}
          localeBindings: {}
          actions: { 'focus': 'glow' }
          index: 0
          length: 33

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token


