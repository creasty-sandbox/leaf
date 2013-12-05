
class Inflector

  regularizeRegExp = (pattern) -> new RegExp pattern.source || pattern, 'gi'

  detect = (word, rules) ->
    result = word
    _(rules).detect (r) -> result = word.replace r[0], r[1] if r[0].test word
    result

  constructor: -> @reset()

  plural: (rule, replacement) -> @plurals.unshift [regularizeRegExp(rule), replacement]

  pluralize: (word, count, withNumber) ->
    if count?
      count = Math.round count
      result = if count == 1 then @singularize word else @pluralize word
      if withNumber
        [count, result].join ' '
      else
        result
    else
      return word if ~@uncountables.indexOf word
      detect word, @plurals

  singular: (rule, replacement) -> @singulars.unshift [regularizeRegExp(rule), replacement]

  singularize: (word) ->
    return word if ~@uncountables.indexOf word
    detect word, @singulars

  irregular: (singular, plural) ->
    @plural "\\b#{singular}\\b", plural
    @singular "\\b#{plural}\\b", singular

  uncountable: (word) -> @uncountables.unshift word

  reset: ->
    @plurals      = []
    @singulars    = []
    @uncountables = []

    INFLECTOR_PLURALS.forEach (r) => @plural r...
    INFLECTOR_SINGULARS.forEach (r) => @singular r...
    INFLECTOR_IRREGULARS.forEach (r) => @irregular r...
    INFLECTOR_UNCOUNTABLES.forEach (r) => @uncountable r


Leaf.Inflector = new Inflector()

