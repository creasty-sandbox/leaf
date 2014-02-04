
class LeafNumber

  Leaf.Class.mixin.call @, Leaf.Data

  ###
  pluralize: (str, withNumber) ->
    Leaf.Inflector.pluralize(@, num, withNumber).ldata()

  ordinalize: (num) ->
    n = num % 10
    n = 0 if n > 3 || 1 == ((num - n) / 10) % 10

    (num + ['th', 'st', 'nd', 'rd'][n]).ldata()

  klass = @
  _('abs acos asin atan ceil cos exp floor log pow round sin sqrt tan').word().each (method) ->
    klass::[method] = -> Math[method](@, arguments...).ldata()

  KILOBYTE_UNIT = 1024
  MEGABYTE_UNIT = 1024 * KILOBYTE_UNIT
  GIGABYTE_UNIT = 1024 * MEGABYTE_UNIT
  TERABYTE_UNIT = 1024 * GIGABYTE_UNIT
  PETABYTE_UNIT = 1024 * TERABYTE_UNIT
  EXABYTE_UNIT  = 1024 * PETABYTE_UNIT

  byte:     -> @
  kilobyte: -> (@ * KILOBYTE_UNIT).ldata()
  megabyte: -> (@ * MEGABYTE_UNIT).ldata()
  gigabyte: -> (@ * GIGABYTE_UNIT).ldata()
  terabyte: -> (@ * TERABYTE_UNIT).ldata()
  petabyte: -> (@ * PETABYTE_UNIT).ldata()
  exabyte:  -> (@ * EXABYTE_UNIT).ldata()

  SECOND_UNIT    = 1000
  MINUTE_UNIT    = 60 * SECOND_UNIT
  HOUR_UNIT      = 60 * MINUTE_UNIT
  DAY_UNIT       = 24 * HOUR_UNIT
  WEEK_UNIT      = 7 * DAY_UNIT
  FORTNIGHT_UNIT = 2 * WEEK_UNIT
  MONTH_UNIT     = 30 * DAY_UNIT
  YEAR_UNIT      = 12 * MONTH_UNIT

  second:    -> (@ * SECOND_UNIT).ldata()
  minute:    -> (@ * MINUTE_UNIT).ldata()
  hour:      -> (@ * HOUR_UNIT).ldata()
  day:       -> (@ * DAY_UNIT).ldata()
  week:      -> (@ * WEEK_UNIT).ldata()
  fortnight: -> (@ * FORTNIGHT_UNIT).ldata()
  month:     -> (@ * MONTH_UNIT).ldata()
  year:      -> (@ * YEAR_UNIT).ldata()

  since: (reference) ->
    (new Date (reference ? new Date()).getTime() + @).ldata()

  until: (reference) ->
    (new Date (reference ? new Date()).getTime() - @).ldata()

  fromNow: @::since
  ago: @::until
  ###


Leaf.Data.add LeafNumber

