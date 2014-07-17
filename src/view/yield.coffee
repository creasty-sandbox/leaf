
Leaf.Template.registerTag 'yield',
  structure: true

  create: (node, $marker, $parent, obj) ->
    return unless Leaf.hasApp()
    { name } = node.localeBindings
    Leaf.sharedApp.getYieldContentFor name, $marker

