
describe 'String', ->

  describe '#pluralize(count[, withNumber])', ->

    it 'should be defined', ->
      expect(String::pluralize).toBeDefined()

    it 'should pluralize string', ->
      expect('book'.pluralize()).toBe 'books'


  describe '#singularize()', ->

    it 'should be defined', ->
      expect(String::singularize).toBeDefined()

    it 'should singularize string', ->
      expect('books'.singularize()).toBe 'book'


  describe '#dasherize()', ->

    it 'should be defined', ->
      expect(String::dasherize).toBeDefined()

    it 'should replace spaces and underscores to dash', ->
      expect('da  sh_er - ize'.dasherize()).toBe 'da-sh-er-ize'


  describe '#underscore()', ->

    it 'should be defined', ->
      expect(String::underscore).toBeDefined()

    it 'should replace space and dash to underscore, and uncamelize string', ->
      expect('un __ der - scoreMe'.underscore()).toBe 'un_der_score_me'


  describe '#capitalize([lowOtherLetter = false])', ->

    it 'should be defined', ->
      expect(String::capitalize).toBeDefined()

    it 'should capitalize the first letter of string', ->
      expect('hello world'.capitalize()).toBe 'Hello world'

    it 'should capitalize the first letter and lowerize the others with `lowOtherLetter`', ->
      expect('heLLo WoRlD'.capitalize(true)).toBe 'Hello world'


  describe '#camelize([lowFirstLetter = false])', ->

    it 'should be defined', ->
      expect(String::camelize).toBeDefined()

    it 'should camerize underscored and dashed string', ->
      expect('ca_me_Lize-me'.camelize()).toBe 'CaMe_LizeMe'

    it 'should camerize and decapitalize string with `lowFirstLetter`', ->
      expect('came_lize'.camelize(true)).toBe 'cameLize'


  describe '#humanize([lowFirstLetter = false])', ->

    it 'should be defined', ->
      expect(String::humanize).toBeDefined()

    it 'should omit "_id" and "_ids" and convert dash to space', ->
      expect('post_commenter_id'.humanize()).toBe 'Post commenter'

    it 'should humanize and decapitalize string with `lowFirstLetter`', ->
      expect('post_commenter_id'.humanize(true)).toBe 'post commenter'


  describe '#titleize()', ->

    it 'should be defined', ->
      expect(String::titleize).toBeDefined()

    it 'should humanize and capitalize each words', ->
      expect('my_story'.titleize()).toBe 'My Story'

    it 'should not capitalize infinitives, articles, prepositions and coordinating conjunctions', ->
      expect('the_story_of_my_life'.titleize()).toBe 'The Story of My Life'


  describe '#tableize()', ->

    it 'should be defined', ->
      expect(String::tableize).toBeDefined()

    it 'should return table name for string', ->
      expect('userAccount'.tableize()).toBe 'user_accounts'


  describe '#classify()', ->

    it 'should be defined', ->
      expect(String::classify).toBeDefined()

    it 'should return class name for string', ->
      expect('user_accounts'.classify()).toBe 'UserAccount'


  describe '#foreignKey([withUnderscore = true])', ->

    it 'should be defined', ->
      expect(String::foreignKey).toBeDefined()

    it 'should return foreign key for string', ->
      expect('userAccount'.foreignKey()).toBe 'user_account_id'


  describe '#ordinalize()', ->

    it 'should be defined', ->
      expect(String::ordinalize).toBeDefined()

    it 'should ordinalize number in string', ->
      expect('my 1 time'.ordinalize()).toBe 'my 1st time'


