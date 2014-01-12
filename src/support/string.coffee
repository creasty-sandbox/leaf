
class StringSupport extends String

  pluralize: Leaf.Inflector.pluralize

  singularize: Leaf.Inflector.singularize

  camelize: (str, lowFirstLetter = false) ->
    str = str.replace /_([a-z])/g, (_, c) -> c.toUpperCase()
    str = @capitalize str unless lowFirstLetter
    str

  underscore: (str) ->
    str.replace /([a-z])([A-Z])/g, (_, l, r) ->
      "#{l}_#{r.toLowerCase()}"

  humanize: (str, lowFirstLetter = false) ->
    str = str.toLowerCase()
    str = str
      .replace(/(_ids|_id)$/g, '')
      .replace(/_/g, ' ')
    str = @capitalize str unless lowFirstLetter
    str

  capitalize: (str) ->
    str[0].toUpperCase() + str[1..]

  dasherize: (str) ->
    str.replace /[_\s]+/g, '-'

  NON_TITLECASED_WORDS = [
    'and', 'or', 'nor', 'a', 'an', 'the', 'so', 'but', 'to', 'of', 'at',
    'by', 'from', 'into', 'on', 'onto', 'off', 'out', 'in', 'over',
    'with', 'for'
  ]
  titleize: (str) ->
    str = @humanize str
    str = str.replace /\b[a-z]+\b/g, (word) ->
      if word in NON_TITLECASED_WORDS
        word
      else
        @capitalize word

  tableize: (str) ->
    @pluralize @underscore(str)

  classify: (str) ->
    @singularize @camelize(str)

  foreignKey: (str, withUnderscore = true) ->
    @singularize(@underscore(str)) + ('_' if withUnderscore) + 'id'

  ordinalize: (str) ->
    str.replace /\b\d+\b/g, (num) ->
      Leaf.Support.Number.ordinalize parseInt(num)


Leaf.Support.add StringSupport

