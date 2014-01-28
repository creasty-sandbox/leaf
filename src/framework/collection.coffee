
class Leaf.Collection extends Leaf.Object

  constructor: ->
    @_removeHandlers = {}
    @models = new Leaf.ObservableArray()
    @registerModelObserver()
    super()

  registerModelObserver: ->
    @models.observe =>
      patch = @models.getSimplePatch()

      for p in patch
        switch p.method
          when 'insertAt' then @registerHook p.element
          when 'removeAt' then @unregisterHook p.element

  unregisterRemoveHook: (o) ->
    handler = @_removeHandlers[o.toLeafID()]
    return unless handler

    $(window)
    .off(@_getEventName(null, o, 'remove'), handler)
    .off(@_getEventName(null, o, 'destroy'), handler)

  registerRemoveHook: (o) ->
    @unregisterRemoveHook o
    handler = => @removeAt index if ~(index = @indexOf o)
    @_removeHandlers[o.toLeafID()] = handler

    $(window)
    .on(@_getEventName(null, o, 'remove'), handler)
    .on(@_getEventName(null, o, 'destroy'), handler)


###
class Leaf.Collection extends Leaf.ObservableArray

  constructor: (data = []) ->
    super data
    @views = new Leaf.ObservableArray []
###

