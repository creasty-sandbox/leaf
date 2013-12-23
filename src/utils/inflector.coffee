
#  Default definitions
#-----------------------------------------------
INFLECTOR_PLURALS = [
  ['$', 's']
  ['s$', 's']
  ['(ax|test)is$', '$1es']
  ['(octop|vir)us$', '$1i']
  ['(octop|vir)i$', '$1i']
  ['(alias|status)$', '$1es']
  ['(bu)s$', '$1ses']
  ['(buffal|tomat)o$', '$1oes']
  ['([ti])um$', '$1a']
  ['([ti])a$', '$1a']
  ['sis$', 'ses']
  ['(?:([^f])fe|([lr])f)$', '$1$2ves']
  ['(hive)$', '$1s']
  ['([^aeiouy]|qu)y$', '$1ies']
  ['(x|ch|ss|sh)$', '$1es']
  ['(matr|vert|ind)(?:ix|ex)$', '$1ices']
  ['([m|l])ouse$', '$1ice']
  ['([m|l])ice$', '$1ice']
  ['^(ox)$', '$1en']
  ['^(oxen)$', '$1']
  ['(quiz)$', '$1zes']
]

INFLECTOR_SINGULARS = [
  ['s$', '']
  ['(n)ews$', '$1ews']
  ['([ti])a$', '$1um']
  ['((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$', '$1$2sis']
  ['(^analy)ses$', '$1sis']
  ['([^f])ves$', '$1fe']
  ['(hive)s$', '$1']
  ['(tive)s$', '$1']
  ['([lr])ves$', '$1f']
  ['([^aeiouy]|qu)ies$', '$1y']
  ['(s)eries$', '$1eries']
  ['(m)ovies$', '$1ovie']
  ['(x|ch|ss|sh)es$', '$1']
  ['([m|l])ice$', '$1ouse']
  ['(bus)es$', '$1']
  ['(o)es$', '$1']
  ['(shoe)s$', '$1']
  ['(cris|ax|test)es$', '$1is']
  ['(octop|vir)i$', '$1us']
  ['(alias|status)es$', '$1']
  ['^(ox)en', '$1']
  ['(vert|ind)ices$', '$1ex']
  ['(matr)ices$', '$1ix']
  ['(quiz)zes$', '$1']
  ['(database)s$', '$1']
]

INFLECTOR_IRREGULARS = [
  ['person', 'people']
  ['man', 'men']
  ['child', 'children']
  ['sex', 'sexes']
  ['move', 'moves']
  ['cow', 'kine']
]

INFLECTOR_UNCOUNTABLES = [
  'equipment'
  'information'
  'rice'
  'money'
  'species'
  'series'
  'fish'
  'sheep'
  'moose'
  'deer'
  'news'
  'jeans'
]


#  Inflector
#-----------------------------------------------
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


# Singleton
Leaf.Inflector = new Inflector()

