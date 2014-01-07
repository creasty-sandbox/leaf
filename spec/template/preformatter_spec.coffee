
describe 'Leaf.Template.Preformatter(html)', ->

  it 'should be defined', ->
    expect(Leaf.Template.Preformatter).toBeDefined()


  describe 'instantiate without `html`', ->

    it 'should throw an exception', ->
      ctx = ->
        pf = new Leaf.Template.Preformatter()

      expect(ctx).toThrow()


  describe 'instantiate with `html`', ->

    it 'should create an instance', ->
      html = '<p>dummy html</p>'
      pf = new Leaf.Template.Preformatter html
      expect(pf).not.toBeNull()
      expect(pf.constructor).toBe Leaf.Template.Preformatter


describe 'preformatter', ->

  beforeEach ->
    html = '<p>dummy html</p>'
    @pf = new Leaf.Template.Preformatter html


  it 'should have `#html` already', ->
    expect(@pf.html).toBeDefined()


  describe '#getResult()', ->

    it 'should be defined', ->
      expect(@pf.getResult).toBeDefined()

    it 'should return `#html`', ->
      expect(@pf.getResult()).toBe @pf.html


  describe '#stripScriptTags()', ->

    it 'should be defined', ->
      expect(@pf.stripScriptTags).toBeDefined()

    it 'should strip all script tags', ->
      @pf.html = '''
        <div id="greeting">Welcome</div>
        <script>
          var greeting = document.getElementById('greeting');
          if (isInternetExplorer) {
            greeting.innerHTML = 'Suck, get the f*ck out of my site';
          }
        </script>
      '''

      @pf.stripScriptTags()

      expect(@pf.html).toBe '<div id="greeting">Welcome</div>\n'


  describe '#minify()', ->

    it 'should be defined', ->
      expect(@pf.minify).toBeDefined()

    it 'should compress whitespaces', ->
      @pf.html = '''
              a
             b b
           c  c  c
        d   d   d   d
      '''

      @pf.minify()

      expect(@pf.html).toBe 'a b b c c c d d d d'

    it 'should remove space between parent tags and child', ->
      @pf.html = '''
        <div>
          <p>hello</p>
        </div>
      '''

      @pf.minify()

      expect(@pf.html).toBe '<div><p>hello</p></div>'

    it 'should not remove space between slibling tags', ->
      @pf.html = '''
        <strong>Price:</strong> <span>$20</span>
      '''

      @pf.minify()

      expect(@pf.html).toBe '<strong>Price:</strong> <span>$20</span>'


  describe 'Preserve', ->

    beforeEach ->
      @sample = '''
        <div>
          <code>
            some code
          </code>
          <pre><code>
            other code
          </code></pre>
        </div>
      '''


    describe '#preserveTags()', ->

      it 'should be defined', ->
        expect(@pf.preserveTags).toBeDefined()

      it 'should replace <pre> and <code> tags into marker tags', ->
        @pf.html = @sample
        @pf.preserveTags()

        expect(@pf.html).toBe '''
          <div>
            <leaf-preserved-0>
            <leaf-preserved-1>
          </div>
        '''


    describe '#undoPreserveTags()', ->

      it 'should replace marker tags to the original tags', ->
        @pf.html = @sample
        @pf.preserveTags()
        @pf.undoPreserveTags()

        expect(@pf.html).toBe @sample


