
describe 'Leaf.Inflector', ->

  it 'should be defined', ->
    expect(Leaf.Inflector).toBeDefined()

  it 'should be singleton', ->
    expect(Leaf.Inflector.constructor.name).toBe 'Inflector'


  beforeEach ->
    Leaf.Inflector.reset()


  describe '.pluralize(word [, count [, widthNumber]]', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.pluralize).toBeDefined()

    it 'should pluralize the given noun', ->
      expect(Leaf.Inflector.pluralize('post')).toEqual 'posts'

    it 'should return the same word if it cannot be pluralized', ->
      expect(Leaf.Inflector.pluralize('posts')).toEqual 'posts'


    describe 'with `count`', ->

      it 'should pluralize the word if not 1', ->
        expect(Leaf.Inflector.pluralize('post', 0)).toEqual 'posts'

      it 'should pluralize the word if not "1"', ->
        expect(Leaf.Inflector.pluralize('post', '0')).toEqual 'posts'

      it 'should pluralize the word if non-1 float', ->
        expect(Leaf.Inflector.pluralize('post', 1.5)).toEqual 'posts'

      it 'should not pluralize the word if 1', ->
        expect(Leaf.Inflector.pluralize('post', 1)).toEqual 'post'

      it 'should singularize the word if 1', ->
        expect(Leaf.Inflector.pluralize('posts', 1)).toEqual 'post'

      it 'should singularize the word if "1"', ->
        expect(Leaf.Inflector.pluralize('posts', '1')).toEqual 'post'


      describe 'and `widthNumber` is true', ->

        it 'should include the word with the plural', ->
          expect(Leaf.Inflector.pluralize('post', 0, true)).toEqual '0 posts'

        it 'should include the word with the singular', ->
          expect(Leaf.Inflector.pluralize('post', 1, true)).toEqual '1 post'


  describe '.plural(rule, replacement)', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.plural).toBeDefined()

    it 'should add a new pluralization rule by explict string', ->
      Leaf.Inflector.plural 'axis', 'axes'

      expect(Leaf.Inflector.pluralize('axis')).toEqual 'axes'

    it 'should add a new pluralization rule by regex', ->
      Leaf.Inflector.plural /(ax)is$/i, '$1es'

      expect(Leaf.Inflector.pluralize('axis')).toEqual 'axes'


  describe '.singularize(word)', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.singularize).toBeDefined()

    it 'should singularize the given noun', ->
      expect(Leaf.Inflector.singularize('posts')).toEqual 'post'

    it 'should return the same word if it cannot be singularized', ->
      expect(Leaf.Inflector.singularize('post')).toEqual 'post'

    it 'should singularize a word that contains an irregular', ->
      expect(Leaf.Inflector.singularize('comments')).toEqual 'comment'


  describe '.singular(rule, replacement)', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.singular).toBeDefined()

    it 'should add a new singularization rule by explicit string', ->
      Leaf.Inflector.singular 'data', 'datum'

      expect(Leaf.Inflector.singularize('data')).toEqual 'datum'

    it 'should add a new singularization rule by regex', ->
      Leaf.Inflector.singular /(t)a$/i, '$1um'

      expect(Leaf.Inflector.singularize('data')).toEqual 'datum'


  describe '.irregular(singular, plural)', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.irregular).toBeDefined()

    it 'should add a rule to pluralize the special case', ->
      Leaf.Inflector.irregular 'number', 'numb3rs'

      expect(Leaf.Inflector.pluralize('number')).toEqual 'numb3rs'

    it 'should add a rule to singularize the special case', ->
      Leaf.Inflector.irregular 'number', 'numb3rs'

      expect(Leaf.Inflector.singularize('numb3rs')).toEqual 'number'


  describe '.uncountable(word)', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.uncountable).toBeDefined()

    it 'should note the word as a special case in pluralization', ->
      Leaf.Inflector.uncountable 'qwerty'

      expect(Leaf.Inflector.pluralize('qwerty')).toEqual 'qwerty'

    it 'should note the word as a special case in singularization', ->
      Leaf.Inflector.uncountable 'qwerty'

      expect(Leaf.Inflector.singularize('qwerty')).toEqual 'qwerty'


  describe '.reset()', ->

    it 'should be defined', ->
      expect(Leaf.Inflector.reset).toBeDefined()

    it 'should reset the default inflections', ->
      Leaf.Inflector.plural 'number', 'numb3rs'

      expect(Leaf.Inflector.pluralize('number')).toEqual 'numb3rs'

      Leaf.Inflector.reset()

      expect(Leaf.Inflector.pluralize('number')).toEqual 'numbers'

