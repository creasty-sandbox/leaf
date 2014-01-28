
class DateSupport

  MONTHS = _.w 'January February March April May June July August September October November December'
  ABBR_MONTHS = _.w 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'

  WEEKDAYS = _.w 'Sunday Monday Tuesday Wednesday Thursday Friday Saturday'
  ABBR_WEEKDAYS = _.w 'Sun Mon Tue Wed Thu Fri Sat'

  RELATIVE_DATE_OUTPUT =
    today:       'today'
    yesterday:   'yesterday'
    tomorrow:    'tomorrow'
    hour_format: '%H:%M, '
    date_format: '%b %o'
    year_format: ', %Y'

  RELATIVE_TIME_RANGES =
    0:  'less than a minute'
    15: 'minute'
    25: 'less than half an hour'
    35: 'about half an hour'
    55: 'less than an hour'
    65: 'about an hour'
    85: 'less than an hour and a half'
    95: 'about an hour and a half'
    115: 'less than 2 hours'
    125: 'about 2 hours'
    145: 'less than 2 hours and a half'
    155: 'about 2 hours and a half'
    175: 'less than 3 hours'
    185: 'around 3 hours'

  class FormatterNotImplementedError extends Leaf.Error

  DATE_FORMATTERS =
    '%a': (date) -> ABBR_WEEKDAYS[date.getDay()]
    '%A': (date) -> WEEKDAYS[date.getDay()]
    '%b': (date) -> ABBR_MONTHS[date.getMonth()]
    '%B': (date) -> MONTHS[date.getMonth()]
    '%c': (date) -> date.toLocaleString()
    '%d': (date) -> date.getDate().padding 2
    '%H': (date) -> date.getHours().padding 2
    '%I': (date) -> (date.getHours() % 12).padding 2
    '%j': (date) -> throw new FormatterNotImplementedError '%j'
    '%m': (date) -> (date.getMonth() + 1).padding 2
    '%M': (date) -> date.getMinutes().padding 2
    '%o': (date) -> date.getDate().ordinalize()
    '%p': (date) -> if Math.floor(date.getHour() / 12) == 0 then 'AM' else 'PM'
    '%S': (date) -> date.getSeconds().padding 2
    '%U': (date) -> throw new FormatterNotImplementedError '%U'
    '%W': (date) -> throw new FormatterNotImplementedError '%W'
    '%w': (date) -> date.getDay()
    '%x': (date) -> throw new FormatterNotImplementedError '%x'
    '%X': (date) -> throw new FormatterNotImplementedError '%X'
    '%y': (date) -> date.getYear().padded 2
    '%Y': (date) -> date.getFullYear().padding 4
    '%Z': (date) -> throw new FormatterNotImplementedError '%Z'

  @now: -> new Date()
  @today: -> @now().atBeginningOfDay()

  equals: (date, other) ->
    date.getFullYear() == other.getFullYear() \
    && date.getMonth() == other.getMonth() \
    && date.getDate() == other.getDate()

  isLeapYear: (date) ->
    year = date.getFullYear()
    (year % 4 == 0 && year % 100 != 0) || year % 400

  getMonthName: (date) -> MONTHS[date.getMonth()]

  getDaysInMonth: (date) ->
    switch date.getMonth() + 1
      when 2
        if @isLeapYear date
          29
        else
          28
      when 4, 6, 9, 11 then 30
      else 31

  isToday: (date) ->
    @equals @beginningOfDay(date), @beginningOfDay(new Date())

  toFormattedString: (date, format) ->
    format
    .replace /(^|[^%])%([a-zA-Z])/g, (_, hack, f) ->
      hack + DATE_FORMATTERS[f]?(date)
    .replace /%%/g, '%'

  relativeDate: (date) ->
    targetTime = @beginningOfDay date
    today = @constructor.today()

    if @equals today, targetTime
      RELATIVE_DATE_OUTPUT['today']
    else if @equals @yesterday(today), targetTime
      RELATIVE_DATE_OUTPUT['yesterday']
    else if @equals @tommorow(today), targetTime
      RELATIVE_DATE_OUTPUT['tomorrow']
    else
      format = RELATIVE_DATE_OUTPUT['date_format']

      if targetTime.getFullYear() == today.getFullYear()
        format += Date.RELATIVE_DATE_OUTPUT['year_format']

      @toFormattedString format

  relativeTime: (date, options = {}) ->
    options = _.defaults options,
      prefix: ''
      suffix: ''

    distanceInMinutes = Math.round Math.abs(new Date().getTime() - date.getTime()) / 60000

    for min, txt of RELATIVE_TIME_RANGES
      if distanceInMinutes <= pair.first()
        txt = txt?(distanceInMinutes) ? txt
        return "#{options.prefix} #{txt} #{options.suffix}"

    "#{@relativeDate date} at #{@toFormattedString date, '%H:%M'}"

  since: (date, seconds) -> seconds.since date

  ago: (date, seconds) -> date.since -seconds

  beginningOfDay: (date) ->
    new Date(date).setHours(0).setMinutes(0).setSeconds 0

  beginningOfWeek: (date) ->
    daysToSunday = (date.getDay() + 6) % 7
    daysToSunday.days().until date.beginningOfDay()

  beginningOfMonth: (date) -> @beginningOfDay(date).setDate 1

  beginningOfQuarter: (date) ->
    month = [9, 6, 3, 0].detect (m) -> m <= date.getMonth()
    @beginningOfMonth(date).setMonth month

  beginningOfYear: (date) -> @beginningOfMonth(date).setMonth 0

  endOfDay: (date) ->
    new Date(date).setHours(23).setMinutes(59).setSeconds 59

  endOfMonth: (date) ->
    @beginningOfDay(date).setDate date.getDaysInMonth()

  endOfQuarter: (date) ->
    month = [2, 5, 8, 11].detect (m) -> m >= date.getMonth()
    date.setMonth(month).endOfMonth()

  yesterday: (date) -> date.setDate date.getDate() - 1

  tomorrow: (date) -> date.setDate date.getDate() + 1

  # method aliases
  strftime: @::toFormattedString
  midnight: @::beginningOfDay
  monday: @::beginningOfWeek

  klass = @
  WEEKDAYS.forEach (dayName, dayIndex) ->
    klass::["is#{dayName}"] = -> @getDay() % 7 == dayIndex


Leaf.Support.add DateSupport

