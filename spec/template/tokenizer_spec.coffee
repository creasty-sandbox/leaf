
describe 'Tokenizer', ->

  it 'should be defined', ->
    expect(Tokenizer).toBeDefined()


  describe '#getToken', ->

    getTokenizer = (html) ->
      pf = new HtmlPreformatter html
      pf.minify()

      tokenizer = new Tokenizer pf.getHtml()
      tokenizer


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
          attrBindings: { }
          localeBindings: { }
          actions: { }
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
          attrs: { }
          attrBindings: { }
          localeBindings: { }
          actions: { }
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
          attrBindings: { }
          localeBindings: { }
          actions: { }
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

      it 'should return tokens with data binding of attributes', ->
        html = """
          <img class="foo" $src="image.url">
        """
        token =
          type: T_TAG_SELF
          buffer: '<img class="foo" $src="image.url">'
          name: 'img'
          attrs: { 'class': 'foo' }
          attrBindings: { 'src': 'image.url' }
          localeBindings: { }
          actions: { }

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token


      it 'should return tokens with data binding of internal variables', ->
        html = """
          <div $model="model"></div>
        """

        token =
          type: T_TAG_OPEN
          buffer: '<div $model="model">'
          name: 'div'
          attrs: { }
          attrBindings: { }
          localeBindings: { 'model': 'model' }
          actions: { }

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token

      it 'should return tokens with data binding of text nodes', ->
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
          attrBindings: { }
          localeBindings: { }
          actions: { 'focus': 'glow' }
          index: 0
          length: 33

        tk = getTokenizer html
        expect(tk.getToken()).toHaveContents token


