
createDOM = (obj, buffer) ->
  psr = new Leaf.Template.Parser()
  psr.init buffer

  view = new Leaf.Template.View()
  view.init psr.getTree(), obj
  view.getDOM()


describe 'Conditional statements', ->

  describe '<if $condition="expr">', ->

    buffer = '''
      <div>
        <if $condition="age > 20">
          <div id="for_adults"></div>
        </if>
      </div>
    '''

    it 'should create DOM if `$condition` is falsy', ->
      obj = new Leaf.Observable age: 18
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'

    it 'should create DOM if `$condition` is truthy', ->
      obj = new Leaf.Observable age: 27
      $el = createDOM obj, buffer

      expect($el).toContain '#for_adults'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = new Leaf.Observable age: 18
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
      obj = new Leaf.Observable {}
      bufferWithError = '''
        <div>
          <elseif $condition="age > 5">
          </elseif>
        </div>
      '''

      ctx = -> createDOM obj, bufferWithError

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = new Leaf.Observable age: 1
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).not.toContain '#for_kids'

    it 'should create DOM if `$condition` is truthy', ->
      obj = new Leaf.Observable age: 10
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).toContain '#for_kids'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = new Leaf.Observable age: 1
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
      obj = new Leaf.Observable {}
      bufferWithError = '''
        <div>
          <else>
          </else>
        </div>
      '''

      ctx = -> createDOM obj, bufferWithError

      expect(ctx).toThrow()

    it 'should create DOM if `$condition` is falsy', ->
      obj = new Leaf.Observable age: 1
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).not.toContain '#for_kids'
      expect($el).toContain '#for_bady'

    it 'should create DOM if `$condition` is truthy', ->
      obj = new Leaf.Observable age: 10
      $el = createDOM obj, buffer

      expect($el).not.toContain '#for_adults'
      expect($el).toContain '#for_kids'
      expect($el).not.toContain '#for_bady'

    it 'should react to change of the object value and create or detach elements inside the tag', ->
      obj = new Leaf.Observable age: 1
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


describe '<each $model="collection[]">', ->

  obj = null

  beforeEach ->
    obj = new Leaf.Observable
      posts: [
        { id: 1, title: 'Alpha' }
        { id: 2, title: 'Beta' }
        { id: 3, title: 'Gamma' }
      ]


  it 'should iterate a view for each item of a collection', ->
    buffer = '''
      <div>
        <each $post="posts[]">
          <div class="post"></div>
        </each>
      </div>
    '''

    $el = createDOM obj, buffer
    $posts = $el.find '.post'

    expect($posts).toExist()
    expect($posts).toHaveLength 3

  it 'should bind model\'s values to each iterated-view', ->
    buffer = '''
      <div>
        <each $post="posts[]">
          <div class="post" $id="'post_' + post.id">
            <h2>{{ post.title }}</h2>
          </div>
        </each>
      </div>
    '''

    $el = createDOM obj, buffer

    expect($el).toContain '#post_1'
    expect($el).toContain '#post_2'
    expect($el).toContain '#post_3'

    expect($el.find('#post_1 h2')).toHaveText 'Alpha'
    expect($el.find('#post_2 h2')).toHaveText 'Beta'
    expect($el.find('#post_3 h2')).toHaveText 'Gamma'


  describe 'Special variable: modelIndex', ->

    it 'should return current index of an item in the collection', ->
      expect(1 == 0).toBe true


