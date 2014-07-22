_ = require 'lodash'


class LeafID

  _leafID = 0

  constructor: ->
    @_leafID ?= ++_leafID

  toLeafID: -> "__LEAF_ID_#{@_leafID}"

  @isLeafID: (id) ->
    _.isString(id) && id[0...10] == '__LEAF_ID_'


module.exports = LeafID
