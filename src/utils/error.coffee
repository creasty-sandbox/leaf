
#=== Base Error
#==============================================================================================
class Leaf.Error extends Error

  @prefix = '[Leaf]'
  @segment = ' '

  constructor: (args...) ->
    msg = []
    msg.push @constructor.prefix

    type = @getErrorType()
    type += ':' if args.length > 0
    msg.push type

    msg.push @setMessage args...

    @message = _.compact(msg).join ' '

  getErrorType: ->
    @constructor.name
    .replace /([a-z])([A-Z])/g, (_0, _1, _2) ->
      "#{_1} #{_2.toLowerCase()}"

  setMessage: (args...) -> args.join @constructor.segment


#=== General Errors
#==============================================================================================
class RequiredArgumentsError extends Leaf.Error

  @segment = ', '

class DependentMixinError extends Leaf.Error

