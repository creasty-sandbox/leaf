
describe 'Date', ->

  describe '::now()', ->

    it 'should be defined', ->
      expect(Date.now).toBeDefined()

    it 'should return current datetime', ->


  describe '::today()', ->

    it 'should be defined', ->
      expect(Date.today).toBeDefined()

    it 'should return today\'s date', ->
      result = new Date().setHours(0).setMinutes(0).setSeconds 0

      expect(Date.today()).toEqual result


  describe '#equals(other)', ->

    it 'should be defined', ->
      expect(Date::equals).toBeDefined()


  describe '#isLeapYear()', ->

    it 'should be defined', ->
      expect(Date::isLeapYear).toBeDefined()


  describe '#getMonthName()', ->

    it 'should be defined', ->
      expect(Date::getMonthName).toBeDefined()


  describe '#getDaysInMonth()', ->

    it 'should be defined', ->
      expect(Date::getDaysInMonth).toBeDefined()


  describe '#isToday()', ->

    it 'should be defined', ->
      expect(Date::isToday).toBeDefined()


  describe '#toFormattedString(format)', ->

    it 'should be defined', ->
      expect(Date::toFormattedString).toBeDefined()


  describe '#relativeDate()', ->

    it 'should be defined', ->
      expect(Date::relativeDate).toBeDefined()


  describe '#relativeTime(options = {})', ->

    it 'should be defined', ->
      expect(Date::relativeTime).toBeDefined()


  describe '#since(seconds)', ->

    it 'should be defined', ->
      expect(Date::since).toBeDefined()


  describe '#ago(seconds)', ->

    it 'should be defined', ->
      expect(Date::ago).toBeDefined()


  describe '#beginningOfDay()', ->

    it 'should be defined', ->
      expect(Date::beginningOfDay).toBeDefined()


  describe '#beginningOfWeek()', ->

    it 'should be defined', ->
      expect(Date::beginningOfWeek).toBeDefined()


  describe '#beginningOfMonth()', ->

    it 'should be defined', ->
      expect(Date::beginningOfMonth).toBeDefined()


  describe '#beginningOfQuarter()', ->

    it 'should be defined', ->
      expect(Date::beginningOfQuarter).toBeDefined()


  describe '#beginningOfYear()', ->

    it 'should be defined', ->
      expect(Date::beginningOfYear).toBeDefined()


  describe '#endOfDay()', ->

    it 'should be defined', ->
      expect(Date::endOfDay).toBeDefined()


  describe '#endOfMonth()', ->

    it 'should be defined', ->
      expect(Date::endOfMonth).toBeDefined()


  describe '#endOfQuarter()', ->

    it 'should be defined', ->
      expect(Date::endOfQuarter).toBeDefined()


  describe '#yesterday', ->

    it 'should be defined', ->
      expect(Date::yesterday).toBeDefined()


  describe '#tomorrow()', ->

    it 'should be defined', ->
      expect(Date::tomorrow).toBeDefined()


  describe '#strftime -> #toFormattedString', ->

    it 'should be defined', ->
      expect(Date::strftime).toBeDefined()


  describe '#midnight -> #beginningOfDay', ->

    it 'should be defined', ->
      expect(Date::midnight).toBeDefined()


  describe '#monday -> beginningOfWeek', ->

    it 'should be defined', ->
      expect(Date::monday).toBeDefined()


