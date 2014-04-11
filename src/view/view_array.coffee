
class Leaf.ViewArray

  constructor: (@$head) ->
    @_views = []

  push: (view) ->
    view.insertAfter @$head
    @_views.push view.$view

  insertAt: (index, view) ->
    if ($idx = @_views[index])
      view.$view.insertBefore $idx
    else
      view.$view.insertAfter @$head

    @_views.splice index, -1, view

  removeAt: (index) ->
    view = @_views[index]
    view.detach()
    @_views.splice index

  swap: (i, j) ->
    vi = @_views[i]
    vj = @_views[j]

    vi.insertBefore vj

    vi = @_views[i]
    vj.insertBefore vi

    tmp = @_views[i]
    @_views[i] = @_views[j]
    @_views[j] = tmp


