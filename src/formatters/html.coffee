
class Leaf.Formatter.HTML

  constructor: (@html) ->

  minify: ->
    @html = @html
      .replace(/\s+/g, ' ')
      .replace />\s+</g, '><'

  getHtml: -> @html

