
class Leaf.Controller extends Leaf.Object

  @setObjectType()

  initialize: ->

  render: (args...) ->
    option = Leaf.Utils.extractOptions args
    @_renderTemplate = args[0]
    @_renderOption = option

  @render: (action) ->
    @ctrl ?= new @()

    _prev = _.keys @ctrl
    @ctrl[action]()
    vars = _.pick @ctrl, _.without(_.keys(@ctrl), _prev...)

    # TODO
    # render template with vars
    # initialize views

