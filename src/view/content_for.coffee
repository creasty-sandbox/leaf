
Leaf.Template.registerTag 'content-for',
  structure: true

  create: (node, $marker, $parent, obj) ->
    return unless Leaf.hasApp()
    { name } = node.localeBindings

    view = new Leaf.Template.DOMGenerator()

    binder = new Leaf.Template.Binder obj
    bindingObj = binder.getBindingObject node.localeBindings

    view.init node.contents, bindingObj

    $el = view.getDOM()
    Leaf.sharedApp.setYieldContentFor name, $el

