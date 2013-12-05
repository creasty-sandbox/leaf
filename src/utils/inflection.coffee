
class Inflector

  constructor: ->
    @reset()

  gsub: (word, rule, replacement) ->
    pattern = new RegExp rule.source || rule, 'gi'
    word.replace pattern, replacement if pattern.test word

  plural: (rule, replacement) -> @plurals.unshift [rule, replacement]

  pluralize: (word, count, includeNumber) ->
    if count?
      count = Math.round count
      result = if count == 1 then @singularize word else @pluralize word
      result = if includeNumber then [count, result].join ' ' else result
    else
      return word if ~@uncountables.indexOf word

      result = word

      _(@plurals).detect (rule) =>
        gsub = @gsub word, rule[0], rule[1]
        if gsub
          result = gsub
        else
          false

    result

  singular: (rule, replacement) -> @singulars.unshift [rule, replacement]

  singularize: (word) ->
    return word if ~@uncountables.indexOf word

    result = word

    _(@singulars).detect (rule) =>
      gsub = @gsub word, rule[0], rule[1]
      if gsub
        result = gsub
      else
        false

    result

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
    INFLECTOR_UNCOUNTABLES.forEach (r) => @uncountable r...


Leaf.Inflector = new Inflector()

