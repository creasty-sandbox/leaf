
describe 'Leaf.Template.Tokenizer', ->

  it 'should be defined', ->
    expect(Leaf.Template.Tokenizer).toBeDefined()

  it 'should create an instance', ->
    tk = new Leaf.Template.Tokenizer()
    expect(tk).not.toBeNull()
    expect(tk.constructor).toBe Leaf.Template.Tokenizer


describe 'tokenizer', ->

  describe '#eat', ->

    it 'should pop buffer by a length of token and return token', ->
      tk = new Leaf.Template.Tokenizer '1234$'

      expect(tk.buffer).toEqual '1234$'

      token = length: 4
      ate = tk.eat token

      expect(ate).toBe token
      expect(tk.buffer).toEqual '$'


  describe '#getText(buffer)', ->

    it 'should return T_NONE token when `buffer` is empty', ->
      tk = new Leaf.Template.Tokenizer()
      token = type: T_NONE
      expect(tk.getText('')).toHaveContents token

    it 'should return T_TEXT token when `buffer` is not empty', ->
      tk = new Leaf.Template.Tokenizer()

      buffer = 'text text'
      token =
        type: T_TEXT
        buffer: buffer
        index: 0
        length: buffer.length

      expect(tk.getText(buffer)).toHaveContents token


  describe '#getInterpolation(buffer)', ->

    it 'should return T_NONE token when there is no interpolations in `buffer`', ->
      tk = new Leaf.Template.Tokenizer()

      buffer = 'no interpolations in here'
      token = type: T_NONE

      expect(tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_NONE token for backslash-escaped interpolations', ->
      tk = new Leaf.Template.Tokenizer()

      buffer = 'no \\{{ interpolations }} in here'
      token = type: T_NONE

      expect(tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_INTERPOLATION token when `buffer` contains interpolations', ->
      tk = new Leaf.Template.Tokenizer()

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
      tk = new Leaf.Template.Tokenizer()

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


  describe '#getTag(buffer)', ->

    it 'should return T_NONE token when `buffer` is empty', ->
      tk = new Leaf.Template.Tokenizer()
      token = type: T_NONE
      expect(tk.getTag('')).toHaveContents token

    it 'should return T_TAG_OPEN token for opening tags', ->
      tk = new Leaf.Template.Tokenizer()

      buffer = 'text <div id="foo">'
      token =
        type: T_TAG_OPEN
        buffer: '<div id="foo">'
        attrPart: ' id="foo"'
        name: 'div'
        index: 5
        length: 14

      expect(tk.getTag(buffer)).toHaveContents token

    it 'should return T_TAG_CLOSE token for closing tag', ->
      tk = new Leaf.Template.Tokenizer()

      buffer = 'text</div>'
      token =
        type: T_TAG_CLOSE
        buffer: '</div>'
        name: 'div'
        index: 4
        length: 6

      expect(tk.getTag(buffer)).toHaveContents token

    it 'should return T_TAG_SELF token for self closing tag', ->
      tk = new Leaf.Template.Tokenizer()

      buffer = 'text <img src="img.gif">'
      token =
        type: T_TAG_SELF
        buffer: '<img src="img.gif">'
        attrPart: ' src="img.gif"'
        name: 'img'
        index: 5
        length: 19

      expect(tk.getTag(buffer)).toHaveContents token


  describe '#getToken', ->

    getTokenizer = (html) ->
      pf = new Leaf.Formatter.HTML html
      pf.minify()

      tokenizer = new Leaf.Template.Tokenizer pf.getHtml()
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
          attrPart: ' id="foo" class="bar"'
          name: 'div'
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
          attrPart: ''
          name: 'i'
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
          attrPart: ' src="img.gif"'
          name: 'img'
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


