
class Leaf.Collection extends Leaf.Object

  constructor: ->
    @_detachHandlers = {}
    @models = new Leaf.ObservableArray()
    @registerModelObserver()
    super()

  _hookDetach: ->
    @observe =>
      patch = @getSimplePatch()

      for p in patch
        switch p.method
          when 'insertAt' then @_hookDetacherOn p.element
          when 'removeAt' then @_unhookDetacherOn p.element

  _unhookDetacherOn: (o) ->
    handler = @_detachHandlers[o._observableID]
    return unless handler

    $(window).off @_getEventName(null, 'detach'), handler

  _hookDetacherOn: (o) ->
    @unhookDetacherOn o
    handler = => @removeAt index if ~(index = @indexOf o)
    @_detachHandlers[o._observableID] = handler

    $(window).on @_getEventName(null, 'detach'), handler


###
class Leaf.Collection extends Leaf.ObservableArray

  constructor: (data = []) ->
    super data
    @views = new Leaf.ObservableArray []
###

