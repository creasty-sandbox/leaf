
class Leaf.Identifiable

  _leafID = 0

  __indentifiable: true

  constructor: ->
    @_leafID ?= ++_leafID

  toLeafID: -> "__LEAF_ID_#{@_leafID}"

  @isLeafID: (id) ->
    _.isString(id) && id[0...10] == '__LEAF_ID_'

