
class NoPartialBindingWithRenderTagError extends Leaf.Error
class PartialPathResolveError extends Leaf.Error


Leaf.Template.registerTag 'render',
  structure: true

  open: (node, parent) ->
    unless node.localeBindings.partial
      throw new NoPartialBindingWithRenderTagError()

  create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()

    binder = new Leaf.Template.Binder obj
    bindingObj = binder.getBindingObject node.localeBindings

    if Leaf.hasApp()
      { partial } = node.localeBindings
      tree = Leaf.app.getPartial partial, node

      unless tree
        throw new PartialPathResolveError partial

      view.init tree, bindingObj

      $el = view.getDOM()
      $el.appendTo $parent

