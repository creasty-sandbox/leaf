
class Leaf.Formatter.HTML

  @minify: (html) ->
    html = html
      .replace(/\s+/g, ' ')
      .replace />\s+</g, '><'

    html

