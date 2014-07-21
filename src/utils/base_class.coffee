singleton = require './singleton'
Mixin     = require './mixin'


class BaseClass

  @setClassName: (@className) ->

  @singleton: ->
    singleton @, @className

  @mixin: (mixin) ->
    Mixin.include @, mixin

  initMixin: ->
    Mixin.initMixin @, arguments...


make = (klass) ->
  Mixin.include klass, BaseClass


module.exports = { make }
