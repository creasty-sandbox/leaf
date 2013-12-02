
class Leaf.Object

  _id = 0

  needAppError = -> throw new Error 'need to be called by app'

  @_objectType = 'Object'

  constructor: ->
    @_c = @constructor
    @_id = ++_id

  hasApp: -> !!@_c.app
  getApp: ->
    needAppError() unless !!@_c.app
    @_c.app
  getAppObserver: -> @getApp().observer
  getAppName: -> @getApp().appName

  getLeafClass: -> "Leaf.#{@_c._objectType}"

  toString: ->
    appName = if @hasApp() then @getAppName() + '.' else ''
    id = "0000#{@_id.toString(16)}"[-4..]
    "#<#{appName}#{@_c.name}:0x#{id}>"


