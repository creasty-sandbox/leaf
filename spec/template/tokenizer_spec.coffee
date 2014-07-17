
describe 'new Leaf.Template.Tokenizer(buffer)', ->

  DUMMY_BUFFER = 'buffer'


  it 'should throw an exception if `buffer` is not given', ->
    ctx = => new Leaf.Template.Tokenizer()
    expect(ctx).toThrow()

  it 'should initialize index pointer and token queues', ->
    tk = new Leaf.Template.Tokenizer DUMMY_BUFFER
    expect(tk.index).toBe 0
    expect(tk.tokens).toEqual {}


  describe '#eat', ->

    it 'should pop buffer by a length of token and return token', ->
      tk = new Leaf.Template.Tokenizer '1234$'

      expect(tk.buffer).toEqual '1234$'

      token = length: 4
      ate = tk.eat token

      expect(ate).toBe token
      expect(tk.buffer).toEqual '$'


  describe '#getText(buffer)', ->

    beforeEach ->
      @tk = new Leaf.Template.Tokenizer DUMMY_BUFFER


    it 'should return T_NONE token when `buffer` is empty', ->
      token = type: T_NONE
      expect(@tk.getText('')).toHaveContents token

    it 'should return T_TEXT token when `buffer` is not empty', ->
      buffer = 'text text'
      token =
        type: T_TEXT
        buffer: buffer
        index: 0
        length: buffer.length

      expect(@tk.getText(buffer)).toHaveContents token


  describe '#getInterpolation(buffer)', ->

    beforeEach ->
      @tk = new Leaf.Template.Tokenizer DUMMY_BUFFER


    it 'should return T_NONE token when there is no interpolations in `buffer`', ->
      buffer = 'no interpolations in here'
      token = type: T_NONE

      expect(@tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_NONE token for backslash-escaped interpolations', ->
      buffer = 'no \\{{ interpolations }} in here'
      token = type: T_NONE

      expect(@tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_INTERPOLATION token when `buffer` contains interpolations', ->
      buffer = 'here goes an {{ interpolation }}'
      token =
        type: T_INTERPOLATION
        buffer: '{{ interpolation }}'
        index: 13
        length: 19
        textBinding:
          val: 'interpolation'
          escape: true

      expect(@tk.getInterpolation(buffer)).toHaveContents token

    it 'should return T_INTERPOLATION token with no escape option for raw interpolations', ->
      buffer = 'it is {{{ raw }}}'
      token =
        type: T_INTERPOLATION
        buffer: '{{{ raw }}}'
        index: 6
        length: 11
        textBinding:
          val: 'raw'
          escape: false

      expect(@tk.getInterpolation(buffer)).toHaveContents token


  describe '#getTag(buffer)', ->

    beforeEach ->
      @tk = new Leaf.Template.Tokenizer DUMMY_BUFFER


    it 'should return T_NONE token when `buffer` is empty', ->
      token = type: T_NONE
      expect(@tk.getTag('')).toHaveContents token

    it 'should return T_TAG token for opening tags', ->
      buffer = 'text <div id="foo">'
      token =
        type: T_TAG
        buffer: '<div id="foo">'
        attrPart: ' id="foo"'
        closing: false
        selfClosing: false
        name: 'div'
        index: 5
        length: 14

      expect(@tk.getTag(buffer)).toHaveContents token

    it 'should return T_TAG token for closing tag', ->
      buffer = 'text</div>'
      token =
        type: T_TAG
        buffer: '</div>'
        name: 'div'
        closing: true
        selfClosing: false
        index: 4
        length: 6

      expect(@tk.getTag(buffer)).toHaveContents token

    it 'should return T_TAG token for self closing tag', ->
      buffer = 'text <img src="img.gif" />'
      token =
        type: T_TAG
        buffer: '<img src="img.gif" />'
        name: 'img'
        attrPart: ' src="img.gif"'
        closing: false
        selfClosing: true
        index: 5
        length: 21

      expect(@tk.getTag(buffer)).toHaveContents token


  describe '#getToken', ->

    getTokenizer = (buffer) ->
      preformatter = new Leaf.Template.Preformatter buffer
      tk = new Leaf.Template.Tokenizer preformatter.getResult()
      tk


    it 'should return T_NONE token when the buffer given is empty', ->
      tk = getTokenizer ''
      expect(tk.getToken()).toHaveContents { type: T_NONE }

    it 'should return tag element and text node tokens', ->
      html = """
        <div id="foo" class="bar">the quick <i>brown</i> fox <img src="img.gif"></div>
      """

      tokens = [
        {
          type: T_TAG
          buffer: '<div id="foo" class="bar">'
          attrPart: ' id="foo" class="bar"'
          name: 'div'
          closing: false
          selfClosing: false
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
          type: T_TAG
          buffer: '<i>'
          attrPart: ''
          name: 'i'
          closing: false
          selfClosing: false
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
          type: T_TAG
          buffer: '</i>'
          name: 'i'
          closing: true
          selfClosing: false
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
          type: T_TAG
          buffer: '<img src="img.gif">'
          name: 'img'
          attrPart: ' src="img.gif"'
          closing: false
          selfClosing: false
          index: 5
          length: 19
        }
        {
          type: T_TAG
          buffer: '</div>'
          name: 'div'
          closing: true
          selfClosing: false
          index: 0
          length: 6
        }
      ]

      tk = getTokenizer html

      expect(tk.getToken()).toHaveContents token for token in tokens

