# Basic set of core binders that are included with Rivets.js.

# Sets the element's text value.
Rivets.binders.text = (el, value) ->
  if el.textContent?
    el.textContent = if value? then value else ''
  else
    el.innerText = if value? then value else ''

# Sets the element's HTML content.
Rivets.binders.html = (el, value) ->
  el.innerHTML = if value? then value else ''

# Shows the element when value is true.
Rivets.binders.show = (el, value) ->
  el.style.display = if value then '' else 'none'

# Hides the element when value is true (negated version of `show` binder).
Rivets.binders.hide = (el, value) ->
  el.style.display = if value then 'none' else ''

# Enables the element when value is true.
Rivets.binders.enabled = (el, value) ->
  el.disabled = !value

# Disables the element when value is true (negated version of `enabled` binder).
Rivets.binders.disabled = (el, value) ->
  el.disabled = !!value

# Checks a checkbox or radio input when the value is true. Also sets the model
# property when the input is checked or unchecked (two-way binder).
Rivets.binders.checked =
  publishes: true
  bind: (el) ->
    $(el).on 'change', @publish
  unbind: (el) ->
    $(el).off 'change', @publish
  routine: (el, value) ->
    if el.type is 'radio'
      el.checked = el.value?.toString() is value?.toString()
    else
      el.checked = !!value

# Unchecks a checkbox or radio input when the value is true (negated version of
# `checked` binder). Also sets the model property when the input is checked or
# unchecked (two-way binder).
Rivets.binders.unchecked =
  publishes: true
  bind: (el) ->
    $(el).on 'change', @publish
  unbind: (el) ->
    $(el).off 'change', @publish
  routine: (el, value) ->
    if el.type is 'radio'
      el.checked = el.value?.toString() isnt value?.toString()
    else
      el.checked = !value

# Sets the element's value. Also sets the model property when the input changes
# (two-way binder).
Rivets.binders.value =
  publishes: true
  bind: (el) ->
    $(el).on 'change', @publish
  unbind: (el) ->
    $(el).off 'change', @publish
  routine: (el, value) ->
    if window.jQuery?
      el = jQuery el

      if value?.toString() isnt el.val()?.toString()
        el.val if value? then value else ''
    else
      if el.type is 'select-multiple'
        o.selected = o.value in value for o in el if value?
      else if value?.toString() isnt el.value?.toString()
        el.value = if value? then value else ''

# Inserts and binds the element and it's child nodes into the DOM when true.
Rivets.binders.if =
  block: true

  bind: (el) ->
    unless @$marker?
      @$el = $ el
      @$marker = $ document.createTextNode ''
      @$contents = @$el.contents()
      @$marker.insertBefore @$el
      @$el.detach()

  routine: (el, value) ->
    if value
      unless @nested
        @nested = new Rivets.View @$contents, @view.models, @view.options
        @nested.bind()

      @$contents.insertBefore @$marker
    else
      @$contents.detach()

  update: (models) ->
    @nested?.update models

# Removes and unbinds the element and it's child nodes into the DOM when true
# (negated version of `if` binder).
Rivets.binders.unless =
  block: true

  bind: (el) ->
    Rivets.binders.if.bind.call @, el

  routine: (el, value) ->
    Rivets.binders.if.routine.call @, el, !value

  update: (models) ->
    Rivets.binders.if.update.call @, models

# Binds an event handler on the element.
Rivets.binders['on-*'] =
  function: true

  unbind: (el) ->
    $(el).off @args[0], @handler if @handler

  routine: (el, value) ->
    $el = $ el
    $el.off @args[0], @handler if @handler
    $el.on @args[0], (@handler = @eventHandler value)

# Appends bound instances of the element in place for each item in the array.
Rivets.binders['each-*'] =
  block: true

  bind: (el) ->
    unless @$marker?
      @$el = $ el
      @$marker = $ document.createTextNode ''
      @iterated = []
      @$marker.insertBefore @$el
      @$item = @$el.contents().clone true
      @$el.remove()
      @$prev = @$marker

  unbind: (el) ->
    view.unbind() for view in @iterated if @iterated?

  routine: (el, collection) ->
    modelName = @args[0]
    collection ||= []

    if @iterated.length > collection.length
      for i in Array @iterated.length - collection.length
        view = @iterated.pop()
        view.unbind()
        $(view.els[0]).remove()

    for model, index in collection
      data = {}
      data[modelName] = model

      if !@iterated[index]?
        data[key] ?= model for key, model of @view.models

        options =
          binders: @view.options.binders
          formatters: @view.options.formatters
          adapters: @view.options.adapters
          config: {}

        options.config[k] = v for k, v of @view.options.config
        options.config.preloadData = true

        $template = @$item.clone true
        view = new Rivets.View $template, data, options
        view.bind()
        @iterated.push view
        $template.insertAfter @$prev
        @$prev = $ view.els[view.els.length - 1]
      else if @iterated[index].models[modelName] isnt model
        @iterated[index].update data

    # if el.nodeName is 'OPTION'
    #   for binding in @view.bindings
    #     if binding.el is @marker.parentNode and binding.type is 'value'
    #       binding.sync()

  update: (models) ->
    data = {}

    for key, model of models
      data[key] = model unless key is @args[0]

    view.update data for view in @iterated

# Adds or removes the class from the element when value is true or false.
Rivets.binders['class-*'] = (el, value) ->
  elClass = " #{el.className} "

  if !value is (elClass.indexOf(" #{@args[0]} ") isnt -1)
    el.className = if value
      "#{el.className} #{@args[0]}"
    else
      elClass.replace(" #{@args[0]} ", ' ').trim()

# Sets the attribute on the element. If no binder above is matched it will fall
# back to using this binder.
Rivets.binders['*'] = (el, value) ->
  if value
    el.setAttribute @type, value
  else
    el.removeAttribute @type

