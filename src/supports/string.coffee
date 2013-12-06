
#  Inflector
#-----------------------------------------------
String::pluralize = (count, withNumber) ->
  Leaf.Inflector.pluralize @, count, withNumber

String::singularize = ->
  Leaf.Inflector.singularize @


