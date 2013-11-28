
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

    @plural /$/, 's'
    @plural /s$/, 's'
    @plural /(ax|test)is$/, '$1es'
    @plural /(octop|vir)us$/, '$1i'
    @plural /(octop|vir)i$/, '$1i'
    @plural /(alias|status)$/, '$1es'
    @plural /(bu)s$/, '$1ses'
    @plural /(buffal|tomat)o$/, '$1oes'
    @plural /([ti])um$/, '$1a'
    @plural /([ti])a$/, '$1a'
    @plural /sis$/, 'ses'
    @plural /(?:([^f])fe|([lr])f)$/, '$1$2ves'
    @plural /(hive)$/, '$1s'
    @plural /([^aeiouy]|qu)y$/, '$1ies'
    @plural /(x|ch|ss|sh)$/, '$1es'
    @plural /(matr|vert|ind)(?:ix|ex)$/, '$1ices'
    @plural /([m|l])ouse$/, '$1ice'
    @plural /([m|l])ice$/, '$1ice'
    @plural /^(ox)$/, '$1en'
    @plural /^(oxen)$/, '$1'
    @plural /(quiz)$/, '$1zes'

    @singular /s$/, ''
    @singular /(n)ews$/, '$1ews'
    @singular /([ti])a$/, '$1um'
    @singular /((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/, '$1$2sis'
    @singular /(^analy)ses$/, '$1sis'
    @singular /([^f])ves$/, '$1fe'
    @singular /(hive)s$/, '$1'
    @singular /(tive)s$/, '$1'
    @singular /([lr])ves$/, '$1f'
    @singular /([^aeiouy]|qu)ies$/, '$1y'
    @singular /(s)eries$/, '$1eries'
    @singular /(m)ovies$/, '$1ovie'
    @singular /(x|ch|ss|sh)es$/, '$1'
    @singular /([m|l])ice$/, '$1ouse'
    @singular /(bus)es$/, '$1'
    @singular /(o)es$/, '$1'
    @singular /(shoe)s$/, '$1'
    @singular /(cris|ax|test)es$/, '$1is'
    @singular /(octop|vir)i$/, '$1us'
    @singular /(alias|status)es$/, '$1'
    @singular /^(ox)en/, '$1'
    @singular /(vert|ind)ices$/, '$1ex'
    @singular /(matr)ices$/, '$1ix'
    @singular /(quiz)zes$/, '$1'
    @singular /(database)s$/, '$1'

    @irregular 'person', 'people'
    @irregular 'man', 'men'
    @irregular 'child', 'children'
    @irregular 'sex', 'sexes'
    @irregular 'move', 'moves'
    @irregular 'cow', 'kine'

    'equipment information rice money species series fish sheep jeans'
    .split(' ').forEach (word) => @uncountable word


Leaf.Inflector = new Inflector()

