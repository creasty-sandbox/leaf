
class Leaf.ViewArray

  constructor: (@$head) ->
    @_views = []

  push: (views...) ->
    len = @_views.length

    for view in views
      $last =
        if len
          @_views[len - 1].$view.eq 0
        else
          @$head

      view.$view.insertAfter $last
      @_views.push view
      ++len

    len

  pop: ->
    view = @_views.pop()
    view?.detach()
    view

  unshift: (views...) ->
    i = views.length

    while i--
      view = views[i]
      view.$view.insertAfter @$head

    @_views.unshift views...

  shift: ->
    view = @_views.shift()
    view?.detach()
    view

  insertAt: (index, views...) ->
    len = @_views.length

    if index <= 0
      @unshift view...
    else if index >= len
      @push view...
    else
      for view in views
        view.$view.insertBefore @_views[index].$view.eq 0
        @_views.splice index, -1, view
        ++index

      @_views.length

  removeAt: (index) ->
    view = @_views[index]
    @_views.splice index, 1
    view.detach()
    view

  swap: (i, j) ->
    vi = @_views[i]
    vj = @_views[j]

    return unless vi && vj

    vi.$view.insertBefore vj.$view.eq 0

    $vi =
      if i == 0
        @$head
      else
        @_views[i - 1].$view.eq 0

    vj.$view.insertAfter $vi

    tmp = @_views[i]
    @_views[i] = @_views[j]
    @_views[j] = tmp

    @

  size: -> @_views.length

