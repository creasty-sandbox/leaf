
class Leaf.Template.Preformatter

  REGEXP_SCRIPT_TAG = /<script(?:\s+[^>]*)?>[\s\S]*?<\/script>/g
  REGEXP_PRESERVE_TAG = /<(pre|code)(?:\s+[^>]*)?>([\s\S]*?)<\/\1>/g
  REGEXP_PRESERVED_MARKER = /<leaf-preserved-(\d+)>/g

  constructor: (@html) ->
    @_preserved = []

    @stripScriptTags()
    @preserveTags()
    @minify()
    @undoPreserveTags()

  minify: ->
    @html = @html
      .replace(/\s+/g, ' ')
      .replace(/<([\w\-:]+(?:\s+[^>]*)?)>\s+</g, '<$1><')
      .replace(/<\/([\w\-:]+)>\s+<\/([\w\-:]+)>/g, '</$1></$2>')
      .replace(/^\s+|\s+$/g, '')

  stripScriptTags: ->
    @html = @html.replace REGEXP_SCRIPT_TAG, ''

  preserveTags: ->
    id = 0

    @html = @html.replace REGEXP_PRESERVE_TAG, (_0) =>
      @_preserved[id] = _0
      "<leaf-preserved-#{id++}>"

  undoPreserveTags: ->
    @html = @html.replace REGEXP_PRESERVED_MARKER, (_, id) =>
      @_preserved[+id]

    @_preserved = []

  getResult: -> @html

