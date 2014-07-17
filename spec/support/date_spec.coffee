
describe 'Date', ->

  describe '::now()', ->

    it 'should be defined', ->
      expect(Date.now).toBeDefined()

    it 'should return current datetime', ->
      # untestable


  describe '::today()', ->

    it 'should be defined', ->
      expect(Date.today).toBeDefined()

    it 'should return today\'s date', ->
      result = new Date().setHours(0).setMinutes(0).setSeconds(0).setMilliseconds(0)

      expect(Date.today()).toEqual result


  describe '#equals(other)', ->

    it 'should be defined', ->
      expect(Date::equals).toBeDefined()

    it 'should return true if the objects are the same "date"', ->
      d1 = new Date 2000, 2, 2, 1, 1, 1
      d2 = new Date 2000, 2, 2, 3, 4, 5

      expect(d1.equals(d2)).toBe true
      expect(d2.equals(d1)).toBe true

    it 'should return false if the object are different date', ->
      d1 = new Date 2000, 2, 2, 1, 1, 1
      d2 = new Date 2000, 2, 9, 3, 4, 5

      expect(d1.equals(d2)).toBe false
      expect(d2.equals(d1)).toBe false


  describe '#isLeapYear()', ->

    it 'should be defined', ->
      expect(Date::isLeapYear).toBeDefined()

    it 'should return true if it is leap year', ->
      d = new Date 2004, 0
      expect(d.isLeapYear()).toBe true


  describe '#getMonthName()', ->

    it 'should be defined', ->
      expect(Date::getMonthName).toBeDefined()

    it 'should return name of month', ->
      d = new Date 1993, 8, 21
      expect(d.getMonthName()).toBe 'September'


  describe '#getDaysInMonth()', ->

    it 'should be defined', ->
      expect(Date::getDaysInMonth).toBeDefined()

    it 'should return 31 for January, March, May, July, August, October and December', ->
      d = new Date 2000, 0
      expect(d.getDaysInMonth()).toBe 31

    it 'should return 30 for April, June, September and November', ->
      d = new Date 2000, 3
      expect(d.getDaysInMonth()).toBe 30

    it 'should return 29 for February of leap year', ->
      d = new Date 2004, 1
      expect(d.getDaysInMonth()).toBe 29

    it 'should return 28 for February of normal year', ->
      d = new Date 2005, 1
      expect(d.getDaysInMonth()).toBe 28


  describe '#isToday()', ->

    it 'should be defined', ->
      expect(Date::isToday).toBeDefined()

    it 'should return true for today\'s date', ->
      now = new Date()
      d = new Date now.getFullYear(), now.getMonth(), now.getDate(), 10, 10, 10

      expect(d.isToday()).toBe true


  describe '#toFormattedString(format)', ->

    it 'should be defined', ->
      expect(Date::toFormattedString).toBeDefined()


  describe '#relativeDate()', ->

    it 'should be defined', ->
      expect(Date::relativeDate).toBeDefined()


  describe '#relativeTime(options = {})', ->

    it 'should be defined', ->
      expect(Date::relativeTime).toBeDefined()


  describe '#since(millisec)', ->

    it 'should be defined', ->
      expect(Date::since).toBeDefined()

    it 'is alias for `Number#since`', ->


  describe '#ago(millisec)', ->

    it 'should be defined', ->
      expect(Date::ago).toBeDefined()

    it 'is alias for `Number#ago`', ->


  describe '#beginningOfDay()', ->

    it 'should be defined', ->
      expect(Date::beginningOfDay).toBeDefined()

    it 'should reset hours, minutes and seconds of date', ->
      d = new Date 2000, 2, 2, 10, 10, 10
      bd = d.beginningOfDay()

      expect(bd.getFullYear()).toBe 2000
      expect(bd.getMonth()).toBe 2
      expect(bd.getDate()).toBe 2
      expect(bd.getHours()).toBe 0
      expect(bd.getMinutes()).toBe 0
      expect(bd.getSeconds()).toBe 0


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

    it 'should return date of yesterday', ->
      today = new Date()
      yesterday = (1).day().ago today

      expect(today.yesterday()).toEqual yesterday


  describe '#tomorrow()', ->

    it 'should be defined', ->
      expect(Date::tomorrow).toBeDefined()

    it 'should return date of tomorrow', ->
      today = new Date()
      tomorrow = (1).day().since today

      expect(today.tomorrow()).toEqual tomorrow


  describe '[alias] #strftime -> #toFormattedString', ->

    it 'should be defined', ->
      expect(Date::strftime).toBeDefined()


  describe '[alias] #midnight -> #beginningOfDay', ->

    it 'should be defined', ->
      expect(Date::midnight).toBeDefined()


  describe '[alias] #monday -> beginningOfWeek', ->

    it 'should be defined', ->
      expect(Date::monday).toBeDefined()


