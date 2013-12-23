
#  Component
#-----------------------------------------------
class Leaf.Component

  @components: {}

  @register: (name, node) ->
    Leaf.Component.componets[name] = node.contents
    Leaf.Template.registerTag name, ComponentView

  @get: (name) -> Leaf.Component.componets[name]


#  Error
#-----------------------------------------------
class NoNameAttributeWithComponentTagError extends Leaf.Error


#  Component view
#-----------------------------------------------
class ComponentView

  @structure: true

  @create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init Leaf.Component.get(node.tag), obj
    $el = view.getDOM()
    $el.appendTo $parent


#  Component def tag
#-----------------------------------------------
Leaf.Template.registerTag 'componet',
  structure: true

  open: (node, parent) ->
    { name } = node.attrs

    unless name
      throw new NoNameAttributeWithComponentTagError()

    Leaf.Component.register name, node

