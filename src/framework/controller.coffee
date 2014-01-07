
class Leaf.Controller extends Leaf.Object

  @setObjectType()

  initialize: ->

  render: ->
    { name, option } = _.polymorphic
      'so?': 'name option'
    , arguments

    @_renderTemplate = name
    @_renderOption = option

  @render: (action) ->
    @ctrl ?= new @()

    _prev = _.keys @ctrl
    @ctrl[action]()
    vars = _.pick @ctrl, _.without(_.keys(@ctrl), _prev...)

    # TODO
    # render template with vars
    # initialize views

