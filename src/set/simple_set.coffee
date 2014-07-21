class SimpleSet

  constructor: (contents) ->
    @_contents = []

    if contents
      @push content for content in contents

  push: (o) ->
    @_contents.push unless ~@_contents.indexOf o
    @

  remove: (o) ->
    index = @_contents.indexOf o
    @_contents.splice index, 1 if ~index
    @

  forEach: (callback) ->
    i = 0
    callbacks content, i++ for content in contents
    @

  toArray: -> [@_content...]



module.exports = SimpleSet
