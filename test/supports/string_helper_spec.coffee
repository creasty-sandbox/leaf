{ chai, expect } = require '../test_helpers'
StringHelper     = require '../../src/supports/string_helper'


describe 'StringHelper', ->

  describe '::pluralize(str, count [, withNumber])', ->

    it 'should pluralize string', ->
      expect(StringHelper.pluralize('book')).to.equal 'books'


  describe '::singularize(str)', ->

    it 'should singularize string', ->
      expect(StringHelper.singularize('books')).to.equal 'book'


  describe '::dasherize(str)', ->

    it 'should replace spaces and underscores to dash', ->
      expect(StringHelper.dasherize('da  sh_er - ize')).to.equal 'da-sh-er-ize'


  describe '::underscore(str)', ->

    it 'should replace space and dash to underscore, and uncamelize string', ->
      expect(StringHelper.underscore('un __ der - scoreMe')).to.equal 'un_der_score_me'


  describe '::capitalize(str [, lowOtherLetter = false])', ->

    it 'should capitalize the first letter of string', ->
      expect(StringHelper.capitalize('hello world')).to.equal 'Hello world'

    it 'should capitalize the first letter and lowerize the others with `lowOtherLetter`', ->
      expect(StringHelper.capitalize('heLLo WoRlD', true)).to.equal 'Hello world'


  describe '::camelize(str [, lowFirstLetter = false])', ->

    it 'should camerize underscored and dashed string', ->
      expect(StringHelper.camelize('ca_me_Lize-me')).to.equal 'CaMe_LizeMe'

    it 'should camerize and decapitalize string with `lowFirstLetter`', ->
      expect(StringHelper.camelize('came_lize', true)).to.equal 'cameLize'


  describe '::humanize(str [, lowFirstLetter = false])', ->

    it 'should omit "_id" and "_ids" and convert dash to space', ->
      expect(StringHelper.humanize('post_commenter_id')).to.equal 'Post commenter'

    it 'should humanize and decapitalize string with `lowFirstLetter`', ->
      expect(StringHelper.humanize('post_commenter_id', true)).to.equal 'post commenter'


  describe '::titleize(str)', ->

    it 'should humanize and capitalize each words', ->
      expect(StringHelper.titleize('my_story')).to.equal 'My Story'

    it 'should not capitalize infinitives, articles, prepositions and coordinating conjunctions', ->
      expect(StringHelper.titleize('the_story_of_my_life')).to.equal 'The Story of My Life'


  describe '::tableize(str)', ->

    it 'should return table name for string', ->
      expect(StringHelper.tableize('userAccount')).to.equal 'user_accounts'


  describe '::classify(str)', ->

    it 'should return class name for string', ->
      expect(StringHelper.classify('user_accounts')).to.equal 'UserAccount'


  describe '::foreignKey(str [, withUnderscore = true])', ->

    it 'should return foreign key for string', ->
      expect(StringHelper.foreignKey('userAccount')).to.equal 'user_account_id'


  describe '::ordinalize(str)', ->

    it 'should ordinalize number in string', ->
      expect(StringHelper.ordinalize('my 1 time')).to.equal 'my 1st time'


