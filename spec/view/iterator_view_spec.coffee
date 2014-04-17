
describe 'Iterator statements', ->

  describe '<each $model="collection[]">', ->

    beforeEach ->
      @obj = new Leaf.ObservableObject
        posts: [
          { id: 1, title: 'Alpha' }
          { id: 2, title: 'Beta' }
          { id: 3, title: 'Gamma' }
        ]

    it 'should throw an exception when an iterator variable is not given', ->
      bufferWithError = '''
        <div>
          <each $post="this.posts">
            <div class="post"></div>
          </each>
        </div>
      '''

      ctx = => Leaf.View.parse(bufferWithError)(@obj)

      expect(ctx).toThrow()

    it 'should iterate a view for each item of a collection', ->
      buffer = '''
        <div>
          <each $post="this.posts[]">
            <div class="post"></div>
          </each>
        </div>
      '''

      $el = Leaf.View.parse(buffer)(@obj)

      $items = $el.find '.post'

      expect($items).toExist()
      expect($items).toHaveLength 3

    it 'should bind model\'s values to each iterated-view', ->
      buffer = '''
        <div>
          <each $post="this.posts[]">
            <div class="post">{{ post.title }}</div>
          </each>
        </div>
      '''

      $el = Leaf.View.parse(buffer)(@obj)

      $items = $el.find '.post'

      expect($items.eq(0)).toHaveText 'Alpha'
      expect($items.eq(1)).toHaveText 'Beta'
      expect($items.eq(2)).toHaveText 'Gamma'


    describe 'Special scope variables', ->

      describe '$collection', ->

      describe '$index', ->

        it 'should return current index of an item in the collection', ->
          buffer = '''
            <div>
              <each $post="this.posts[]">
                <div class="post">{{ post.id }}-{{ $index }}</div>
              </each>
            </div>
          '''

          $el = Leaf.View.parse(buffer)(@obj)

          $items = $el.find '.post'

          expect($items.eq(0)).toHaveText '1-0'
          expect($items.eq(1)).toHaveText '2-1'
          expect($items.eq(2)).toHaveText '3-2'


    describe 'Mutator methods', ->

      it 'should react to mutator methods iterated-view', ->
        buffer = '''
          <div>
            <each $post="this.posts[]">
              <div class="post" $id="'post_' + post.id">
                <h2>{{ post.title }}</h2>
              </div>
            </each>
          </div>
        '''

        $el = Leaf.View.parse(buffer)(@obj)

        @obj.posts.push id: 4, title: 'Delta'

        expect($el).toContainElement '#post_4'
        expect($el.find('#post_4 h2')).toHaveText 'Delta'


