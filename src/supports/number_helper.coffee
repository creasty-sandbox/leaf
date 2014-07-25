$w        = require '../utils/word'
Inflector = require './inflector'


class NumberHelper

  @pluralize: (num, str, withNumber) ->
    Inflector.pluralize str, num, withNumber

  @ordinalize: (num) ->
    n = num % 10
    n = 0 if n > 3 || 1 == ((num - n) / 10) % 10

    num + ['th', 'st', 'nd', 'rd'][n]

  klass = @
  $w('abs acos asin atan ceil cos exp floor log pow round sin sqrt tan').forEach (method) ->
    klass[method] = -> Math[method] arguments...

  KILOBYTE_UNIT = 1024
  MEGABYTE_UNIT = 1024 * KILOBYTE_UNIT
  GIGABYTE_UNIT = 1024 * MEGABYTE_UNIT
  TERABYTE_UNIT = 1024 * GIGABYTE_UNIT
  PETABYTE_UNIT = 1024 * TERABYTE_UNIT
  EXABYTE_UNIT  = 1024 * PETABYTE_UNIT

  @byte:     (num) -> +num
  @kilobyte: (num) -> num * KILOBYTE_UNIT
  @megabyte: (num) -> num * MEGABYTE_UNIT
  @gigabyte: (num) -> num * GIGABYTE_UNIT
  @terabyte: (num) -> num * TERABYTE_UNIT
  @petabyte: (num) -> num * PETABYTE_UNIT
  @exabyte:  (num) -> num * EXABYTE_UNIT

  SECOND_UNIT    = 1000
  MINUTE_UNIT    = 60 * SECOND_UNIT
  HOUR_UNIT      = 60 * MINUTE_UNIT
  DAY_UNIT       = 24 * HOUR_UNIT
  WEEK_UNIT      = 7 * DAY_UNIT
  FORTNIGHT_UNIT = 2 * WEEK_UNIT
  MONTH_UNIT     = 30 * DAY_UNIT
  YEAR_UNIT      = 12 * MONTH_UNIT

  @second:    (num) -> num * SECOND_UNIT
  @minute:    (num) -> num * MINUTE_UNIT
  @hour:      (num) -> num * HOUR_UNIT
  @day:       (num) -> num * DAY_UNIT
  @week:      (num) -> num * WEEK_UNIT
  @fortnight: (num) -> num * FORTNIGHT_UNIT
  @month:     (num) -> num * MONTH_UNIT
  @year:      (num) -> num * YEAR_UNIT

  @since: (num, reference) ->
    new Date (reference ? new Date()).getTime() + num

  @until: (num, reference) ->
    new Date (reference ? new Date()).getTime() - num

  @fromNow: (num) -> @since num

  @ago: (num) -> @until num


module.exports = NumberHelper
