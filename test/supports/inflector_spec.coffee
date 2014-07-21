{ chai, expect } = require '../test_helpers'
Inflector        = require '../../src/supports/inflector'


describe 'Inflector', ->

  beforeEach ->
    Inflector.reset()


  describe '.pluralize(word [, count [, widthNumber]])', ->

    it 'should pluralize the given noun', ->
      expect(Inflector.pluralize('post')).to.equal 'posts'

    it 'should return the same word if it cannot be pluralized', ->
      expect(Inflector.pluralize('posts')).to.equal 'posts'


    describe 'with `count`', ->

      it 'should pluralize the word if not 1', ->
        expect(Inflector.pluralize('post', 0)).to.equal 'posts'

      it 'should pluralize the word if not "1"', ->
        expect(Inflector.pluralize('post', '0')).to.equal 'posts'

      it 'should pluralize the word if non-1 float', ->
        expect(Inflector.pluralize('post', 1.5)).to.equal 'posts'

      it 'should not pluralize the word if 1', ->
        expect(Inflector.pluralize('post', 1)).to.equal 'post'

      it 'should singularize the word if 1', ->
        expect(Inflector.pluralize('posts', 1)).to.equal 'post'

      it 'should singularize the word if "1"', ->
        expect(Inflector.pluralize('posts', '1')).to.equal 'post'


      describe 'and `widthNumber` is true', ->

        it 'should include the word with the plural', ->
          expect(Inflector.pluralize('post', 0, true)).to.equal '0 posts'

        it 'should include the word with the singular', ->
          expect(Inflector.pluralize('post', 1, true)).to.equal '1 post'


  describe '.plural(rule, replacement)', ->

    it 'should add a new pluralization rule by explict string', ->
      Inflector.plural 'axis', 'axes'

      expect(Inflector.pluralize('axis')).to.equal 'axes'

    it 'should add a new pluralization rule by regex', ->
      Inflector.plural /(ax)is$/i, '$1es'

      expect(Inflector.pluralize('axis')).to.equal 'axes'


  describe '.singularize(word)', ->

    it 'should singularize the given noun', ->
      expect(Inflector.singularize('posts')).to.equal 'post'

    it 'should return the same word if it cannot be singularized', ->
      expect(Inflector.singularize('post')).to.equal 'post'

    it 'should singularize a word that contains an irregular', ->
      expect(Inflector.singularize('comments')).to.equal 'comment'


  describe '.singular(rule, replacement)', ->

    it 'should add a new singularization rule by explicit string', ->
      Inflector.singular 'data', 'datum'

      expect(Inflector.singularize('data')).to.equal 'datum'

    it 'should add a new singularization rule by regex', ->
      Inflector.singular /(t)a$/i, '$1um'

      expect(Inflector.singularize('data')).to.equal 'datum'


  describe '.irregular(singular, plural)', ->

    it 'should add a rule to pluralize the special case', ->
      Inflector.irregular 'number', 'numb3rs'

      expect(Inflector.pluralize('number')).to.equal 'numb3rs'

    it 'should add a rule to singularize the special case', ->
      Inflector.irregular 'number', 'numb3rs'

      expect(Inflector.singularize('numb3rs')).to.equal 'number'


  describe '.uncountable(word)', ->

    it 'should note the word as a special case in pluralization', ->
      Inflector.uncountable 'qwerty'

      expect(Inflector.pluralize('qwerty')).to.equal 'qwerty'

    it 'should note the word as a special case in singularization', ->
      Inflector.uncountable 'qwerty'

      expect(Inflector.singularize('qwerty')).to.equal 'qwerty'


  describe '.reset()', ->

    it 'should reset the default inflections', ->
      Inflector.plural 'number', 'numb3rs'

      expect(Inflector.pluralize('number')).to.equal 'numb3rs'

      Inflector.reset()

      expect(Inflector.pluralize('number')).to.equal 'numbers'

