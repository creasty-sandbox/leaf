
describe 'Number', ->

  describe '#pluralize(word, withNumber = false)', ->

    it 'should be defined', ->
      expect(Number::pluralize).toBeDefined()

    it 'should return pluralized word', ->
      expect((1).pluralize('book')).toBe 'book'
      expect((2).pluralize('book')).toBe 'books'

    it 'should return pluralized word with count with `withNumber`', ->
      expect((2).pluralize('book', true)).toBe '2 books'


  describe '#ordinalize()', ->

    it 'should be defined', ->
      expect(Number::ordinalize).toBeDefined()

    it 'should ordinalize number', ->
      expect((2).ordinalize()).toBe '2nd'


  describe '#byte()', ->

    it 'should be defined', ->
      expect(Number::byte).toBeDefined()

    it 'should be identical function', ->
      expect((2).byte()).toBe 2


  describe '#kilobyte()', ->

    it 'should be defined', ->
      expect(Number::kilobyte).toBeDefined()

    it 'should return number multiplied by 1024^1', ->
      expect((2).kilobyte()).toBe 2 * Math.pow(1024, 1)


  describe '#megabyte()', ->

    it 'should be defined', ->
      expect(Number::megabyte).toBeDefined()

    it 'should return number multiplied by 1024^2', ->
      expect((2).megabyte()).toBe 2 * Math.pow(1024, 2)


  describe '#gigabyte()', ->

    it 'should be defined', ->
      expect(Number::gigabyte).toBeDefined()

    it 'should return number multiplied by 1024^3', ->
      expect((2).gigabyte()).toBe 2 * Math.pow(1024, 3)


  describe '#terabyte()', ->

    it 'should be defined', ->
      expect(Number::terabyte).toBeDefined()

    it 'should return number multiplied by 1024^4', ->
      expect((2).terabyte()).toBe 2 * Math.pow(1024, 4)


  describe '#petabyte()', ->

    it 'should be defined', ->
      expect(Number::petabyte).toBeDefined()

    it 'should return number multiplied by 1024^5', ->
      expect((2).petabyte()).toBe 2 * Math.pow(1024, 5)


  describe '#exabyte()', ->

    it 'should be defined', ->
      expect(Number::exabyte).toBeDefined()

    it 'should return number multiplied by 1024^6', ->
      expect((2).exabyte()).toBe 2 * Math.pow(1024, 6)


  describe '#second()', ->

    it 'should be defined', ->
      expect(Number::second).toBeDefined()

    it 'should return seconds of number in milisecound', ->
      expect((2).second()).toBe 2 * 1000


  describe '#minute()', ->

    it 'should be defined', ->
      expect(Number::minute).toBeDefined()

    it 'should return minutes of number in milisecound', ->
      expect((2).minute()).toBe 2 * 1000 * 60


  describe '#hour()', ->

    it 'should be defined', ->
      expect(Number::hour).toBeDefined()

    it 'should return hours of number in milisecound', ->
      expect((2).hour()).toBe 2 * 1000 * 60 * 60


  describe '#day()', ->

    it 'should be defined', ->
      expect(Number::day).toBeDefined()

    it 'should return days of number in milisecound', ->
      expect((2).day()).toBe 2 * 1000 * 60 * 60 * 24


  describe '#week()', ->

    it 'should be defined', ->
      expect(Number::week).toBeDefined()

    it 'should return weeks of number in milisecound', ->
      expect((2).week()).toBe 2 * 1000 * 60 * 60 * 24 * 7


  describe '#fortnight()', ->

    it 'should be defined', ->
      expect(Number::fortnight).toBeDefined()

    it 'should return fortnights of number in milisecound', ->
      expect((2).fortnight()).toBe 2 * 1000 * 60 * 60 * 24 * 7 * 2


  describe '#month()', ->

    it 'should be defined', ->
      expect(Number::month).toBeDefined()

    it 'should return months of number in milisecound', ->
      expect((2).month()).toBe 2 * 1000 * 60 * 60 * 24 * 30


  describe '#year()', ->

    it 'should be defined', ->
      expect(Number::year).toBeDefined()

    it 'should return years of number in milisecound', ->
      expect((2).year()).toBe 2 * 1000 * 60 * 60 * 24 * 30 * 12


  describe '#since(reference)', ->

    it 'should be defined', ->
      expect(Number::since).toBeDefined()

    it 'should return a date that milisecounds of number after reference', ->
      ref = new Date()
      result = new Date(+ref + (3).year())

      expect((3).year().since(ref)).toEqual result


  describe '#until(reference)', ->

    it 'should be defined', ->
      expect(Number::until).toBeDefined()

    it 'should return a date that milisecounds of number before reference', ->
      ref = new Date()
      result = new Date(+ref - (3).year())

      expect((3).year().until(ref)).toEqual result


  describe '#fromNow()', ->

    it 'should be defined', ->
      expect(Number::fromNow).toBeDefined()

    it 'should return a date that milisecounds of number after now', ->


  describe '#ago()', ->

    it 'should be defined', ->
      expect(Number::ago).toBeDefined()

    it 'should return a date that milisecounds of number before now', ->


