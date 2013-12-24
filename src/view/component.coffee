
#  Component
#-----------------------------------------------
class Leaf.Component

  @components: {}

  @regularateName: (name) ->
    name
    .replace(/([a-z])([A-Z])/g, ((_0, _1, _2) -> "#{_1}-#{_2.toLowerCase()}"))
    .replace(/[^a-z\-\:]/ig, '')

  @register: (name, node) ->
    name = @regularateName name
    Leaf.Component.componets[name] = node.contents
    Leaf.Template.registerTag name, ComponentView

  @get: (name) ->
    name = @regularateName name
    Leaf.Component.componets[name]


#  Error
#-----------------------------------------------
class NoNameAttributeWithComponentTagError extends Leaf.Error


#  Component view
#-----------------------------------------------
class ComponentView

  @structure: true

  @create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()
    view.init Leaf.Component.get(node.name), obj
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

