
describe 'Iterator statements', ->

  createDOM = (obj, buffer) ->
    psr = new Leaf.Template.Parser()
    psr.init buffer

    gen = new Leaf.Template.DOMGenerator()
    gen.init psr.getTree(), obj
    gen.getDOM()


  describe '<each $model="collection[]">', ->

    beforeEach ->
      @obj = new Leaf.Observable
        posts: [
          { id: 1, title: 'Alpha' }
          { id: 2, title: 'Beta' }
          { id: 3, title: 'Gamma' }
        ]

    it 'should throw an exception when an iterator variable is not given', ->
      buffer = '''
        <div>
          <each $post="posts">
            <div class="post"></div>
          </each>
        </div>
      '''

      ctx = =>
        $el = createDOM @obj, buffer

      expect(ctx).toThrow()

    it 'should iterate a view for each item of a collection', ->
      buffer = '''
        <div>
          <each $post="posts[]">
            <div class="post"></div>
          </each>
        </div>
      '''

      $el = createDOM @obj, buffer
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

      $el = createDOM @obj, buffer

      expect($el).toContain '#post_1'
      expect($el).toContain '#post_2'
      expect($el).toContain '#post_3'

      expect($el.find('#post_1 h2')).toHaveText 'Alpha'
      expect($el.find('#post_2 h2')).toHaveText 'Beta'
      expect($el.find('#post_3 h2')).toHaveText 'Gamma'


    describe 'Special variable: modelIndex', ->

      it 'should return current index of an item in the collection', ->
        expect(1 == 0).toBe true


