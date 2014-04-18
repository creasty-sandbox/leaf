
class NoFileSpecifiedWithRenderTagError extends Leaf.Error
class PartialPathResolveError extends Leaf.Error


Leaf.Template.registerTag 'render',
  structure: true

  open: (node, parent) ->
    unless node.attrBindings.partial && node.attrBindings.poly
      throw new NoFileSpecifiedWithRenderTagError()

  create: (viewData) ->
    if node.attrBindings.partial
      partial = viewData.scope.get 'partial'

      if Leaf.hasApp()
        tree = Leaf.sharedApp.getPartial partial

        unless tree
          throw new PartialPathResolveError partial

        view = Leaf.View
          tree:       tree
          controller: viewData.controller
          scope:      viewData.scope

        view.$view.insertAfter viewData.$marker
        view.render()
    else if node.attrBindings.poly
      component = viewData.scope.get 'component'
      viewData.node.name = Leaf.Component.regulateName component
      ComponentView.create viewData

