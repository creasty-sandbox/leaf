
describe 'Conditional statements', ->

  createDOM = (obj, buffer) ->
    psr = new Leaf.Template.Parser()
    psr.init buffer

    gen = new Leaf.Template.DOMGenerator()
    gen.init psr.getTree(), obj
    gen.getDOM()


  describe '<if $condition="expr">', ->

    buffer = '''
      <div>
        <if $condition="age > 20">
          <div id="for_adults"></div>
        </if>
      </div>
    '''

    it 'should throw an exception when $condition binding is not set', ->
      bufferWithError = '<if></if>'
      obj = {}

      ctx = ->
        createDOM obj, bufferWithError

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = Leaf.Observable age: 18
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'

    it 'should create DOM if `$condition` is truthy', ->
      obj = Leaf.Observable age: 27
      $el = createDOM obj, buffer

      expect($el).toContain '#for_adults'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = Leaf.Observable age: 18
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'

      obj.set 'age', 27

      expect($el).toContain '#for_adults'

      obj.set 'age', 16

      expect($el).not.toContain '#for_adults'


  describe '<elseif $condition="expr">', ->

    buffer = '''
      <div>
        <if $condition="age > 20">
          <div id="for_adults"></div>
        </if>
        <elseif $condition="age > 5">
          <div id="for_kids"></div>
        </elseif>
      </div>
    '''

    it 'should throw an exception if a previous sibling node is not if-statement', ->
      obj = Leaf.Observable {}
      bufferWithError = '''
        <div>
          <elseif $condition="age > 5">
          </elseif>
        </div>
      '''

      ctx = -> createDOM obj, bufferWithError

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = Leaf.Observable age: 1
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).not.toContain '#for_kids'

    it 'should create DOM if `$condition` is truthy', ->
      obj = Leaf.Observable age: 10
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).toContain '#for_kids'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = Leaf.Observable age: 1
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).not.toContain '#for_kids'

      obj.set 'age', 10

      expect($el).not.toContain '#for_adults'
      expect($el).toContain '#for_kids'

      obj.set 'age', 27

      expect($el).toContain '#for_adults'
      expect($el).not.toContain '#for_kids'


  describe '<else>', ->

    buffer = '''
      <div>
        <if $condition="age > 20">
          <div id="for_adults"></div>
        </if>
        <elseif $condition="age > 5">
          <div id="for_kids"></div>
        </elseif>
        <else>
          <div id="for_bady"></div>
        </else>
      </div>
    '''

    it 'should throw an exception if a previous sibling node is not if- nor elseif-statement', ->
      obj = Leaf.Observable {}
      bufferWithError = '''
        <div>
          <else>
          </else>
        </div>
      '''

      ctx = -> createDOM obj, bufferWithError

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = Leaf.Observable age: 1
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).not.toContain '#for_kids'
      expect($el).toContain '#for_bady'

    it 'should create DOM if `$condition` is truthy', ->
      obj = Leaf.Observable age: 10
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).toContain '#for_kids'
      expect($el).not.toContain '#for_bady'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = Leaf.Observable age: 1
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).not.toContain '#for_kids'
      expect($el).toContain '#for_bady'

      obj.set 'age', 10

      expect($el).not.toContain '#for_adults'
      expect($el).toContain '#for_kids'
      expect($el).not.toContain '#for_bady'

      obj.set 'age', 27

      expect($el).toContain '#for_adults'
      expect($el).not.toContain '#for_kids'
      expect($el).not.toContain '#for_bady'


