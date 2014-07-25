Inflector    = require './inflector'
NumberHelper = require './number_helper'


class StringHelper

  NON_TITLECASED_WORDS = [
    'and', 'or', 'nor', 'a', 'an', 'the', 'so', 'but', 'to', 'of', 'at',
    'by', 'from', 'into', 'on', 'onto', 'off', 'out', 'in', 'over',
    'with', 'for'
  ]

  @pluralize: (str, count, withNumber) ->
    Inflector.pluralize str, count, withNumber

  @singularize: (str) ->
    Inflector.singularize str

  @dasherize: (str) ->
    str.replace /[_\s\-]+/g, '-'

  @underscore: (str) ->
    str
    .replace(/[\-\s_]+/g, '_')
    .replace /([a-z])([A-Z])/g, (_, l, r) ->
      "#{l}_#{r.toLowerCase()}"

  @capitalize: (str, lowOtherLetter = false) ->
    other = str[1..]
    other = other.toLowerCase() if lowOtherLetter
    str[0].toUpperCase() + other

  @camelize: (str, lowFirstLetter = false) ->
    str = @underscore(str).replace /_([a-z])/g, (_, c) -> c.toUpperCase()
    str = @capitalize str unless lowFirstLetter
    str

  @humanize: (str, lowFirstLetter = false) ->
    str = str.toLowerCase()
    str = str
      .replace(/(_ids|_id)$/g, '')
      .replace(/_/g, ' ')
    str = @capitalize str unless lowFirstLetter
    str

  @titleize: (str) ->
    str = @humanize str
    str = str.replace /\b[a-z]+\b/g, (word) =>
      if word in NON_TITLECASED_WORDS
        word
      else
        @capitalize word

  @tableize: (str) ->
    @pluralize @underscore(str)

  @classify: (str) ->
    @singularize @camelize(str)

  @foreignKey: (str, withUnderscore = true) ->
    @singularize(@underscore(str)) + ('_' if withUnderscore) + 'id'

  @ordinalize: (str) ->
    str.replace /\b\d+\b/g, (num) -> NumberHelper.ordinalize parseInt(num)


module.exports = StringHelper
