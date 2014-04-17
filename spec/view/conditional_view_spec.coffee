
describe 'Conditional statements', ->

  describe '<if $condition="expr">', ->

    buffer = '''
      <div>
        <if $condition="this.age > 20">
          <div id="for_adults"></div>
        </if>
      </div>
    '''

    it 'should throw an exception when $condition binding is not set', ->
      bufferWithError = '<if></if>'
      obj = {}

      ctx = ->
        Leaf.View.parse(bufferWithError)(obj)

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = new Leaf.ObservableObject age: 18
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'

    it 'should create DOM if `$condition` is truthy', ->
      obj = new Leaf.ObservableObject age: 27
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).toContainElement '#for_adults'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = new Leaf.ObservableObject age: 18
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'

      obj.set 'age', 27

      expect($el).toContainElement '#for_adults'

      obj.set 'age', 16

      expect($el).not.toContainElement '#for_adults'


  describe '<elseif $condition="expr">', ->

    buffer = '''
      <div>
        <if $condition="this.age > 20">
          <div id="for_adults"></div>
        </if>
        <elseif $condition="this.age > 5">
          <div id="for_kids"></div>
        </elseif>
      </div>
    '''

    it 'should throw an exception if a previous sibling node is not if-statement', ->
      obj = new Leaf.ObservableObject()
      bufferWithError = '''
        <div>
          <elseif $condition="this.age > 5">
          </elseif>
        </div>
      '''

      ctx = -> Leaf.View.parse(bufferWithError)(obj)

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = new Leaf.ObservableObject age: 1
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'
      expect($el).not.toContainElement '#for_kids'

    it 'should create DOM if `$condition` is truthy', ->
      obj = new Leaf.ObservableObject age: 10
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'
      expect($el).toContainElement '#for_kids'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = new Leaf.ObservableObject age: 1
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'
      expect($el).not.toContainElement '#for_kids'

      obj.set 'age', 10

      expect($el).not.toContainElement '#for_adults'
      expect($el).toContainElement '#for_kids'

      obj.set 'age', 27

      expect($el).toContainElement '#for_adults'
      expect($el).not.toContainElement '#for_kids'


  describe '<else>', ->

    buffer = '''
      <div>
        <if $condition="this.age > 20">
          <div id="for_adults"></div>
        </if>
        <elseif $condition="this.age > 5">
          <div id="for_kids"></div>
        </elseif>
        <else>
          <div id="for_bady"></div>
        </else>
      </div>
    '''

    it 'should throw an exception if a previous sibling node is not if- nor elseif-statement', ->
      obj = new Leaf.ObservableObject {}
      bufferWithError = '''
        <div>
          <else>
          </else>
        </div>
      '''

      ctx = -> Leaf.View.parse(bufferWithError)(obj)

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = new Leaf.ObservableObject age: 1
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'
      expect($el).not.toContainElement '#for_kids'
      expect($el).toContainElement '#for_bady'

    it 'should create DOM if `$condition` is truthy', ->
      obj = new Leaf.ObservableObject age: 10
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'
      expect($el).toContainElement '#for_kids'
      expect($el).not.toContainElement '#for_bady'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = new Leaf.ObservableObject age: 1
      $el = Leaf.View.parse(buffer)(obj)

      expect($el).not.toContainElement '#for_adults'
      expect($el).not.toContainElement '#for_kids'
      expect($el).toContainElement '#for_bady'

      obj.set 'age', 10

      expect($el).not.toContainElement '#for_adults'
      expect($el).toContainElement '#for_kids'
      expect($el).not.toContainElement '#for_bady'

      obj.set 'age', 27

      expect($el).toContainElement '#for_adults'
      expect($el).not.toContainElement '#for_kids'
      expect($el).not.toContainElement '#for_bady'


