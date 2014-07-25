_            = require 'lodash'
singleton    = require '../utils/singleton'
mixin        = require '../utils/mixin'
StringHelper = require '../supports/string_helper'


class BaseClass

  @setClassName: (@className) ->
    cname = '__' + StringHelper.underscore(@className)

    @[cname] = true
    @::[cname] = true

  @singleton: ->
    singleton @, @className

  @mixin: (klass) ->
    mixin.include @, klass

  initBaseClass: ->

  initMixin: ->
    mixin.initMixin @, arguments...

  inheritFromSuper: (property) ->
    superClass = @constructor.__super__

    return unless superClass

    self = @[property] ? {}
    @[property] = _.defaults self, superClass[property]

  toString: ->
    description = [
      @constructor.className
      @toID()
      JSON.stringify(@toInspect())
    ]

    "<#{_.compact(description).join ' '}>"

  toID: ->

  toInspect: ->


make = (klass) ->
  mixin.include klass, BaseClass


module.exports = { make }
