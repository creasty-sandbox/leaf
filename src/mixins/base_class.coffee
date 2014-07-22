_         = require 'lodash'
singleton = require '../utils/singleton'
Mixin     = require '../utils/mixin'


class BaseClass

  @setClassName: (@className) ->

  @singleton: ->
    singleton @, @className

  @mixin: (mixin) ->
    Mixin.include @, mixin

  initBaseClass: ->

  initMixin: ->
    Mixin.initMixin @, arguments...

  inheritFromSuper: (property) ->
    superClass = @constructor.__super__

    return unless superClass

    self = @[property] ? {}
    @[property] = _.defaults self, superClass[property]

  toString: ->
    description = [
      @constructor.className
      @toID()
      @toInspect()
    ]

    "<#{_.compact(description).join ' '}>"

  toID: ->

  toInspect: ->


make = (klass) ->
  Mixin.include klass, BaseClass


module.exports = { make }
