
#  Component
#-----------------------------------------------
class Leaf.Component extends Leaf.View

  @components: {}

  @regulateName: (name) ->
    return '' unless name

    name
    .replace(/([a-z])([A-Z])/g, ((_0, _1, _2) -> "#{_1}-#{_2.toLowerCase()}"))
    .replace(/\//g, ':')
    .replace(/[^a-z\-:]/ig, '')
    .replace(/\-*:+\-*/g, ':')
    .replace(/\-+/g, '-')
    .replace(/^(\-|:)|(\-|:)$/g, '')
    .replace(/^component:/, '')
    .toLowerCase()

  @register: (name, node) ->
    name = @regulateName name
    Leaf.Component.components[name] = node.contents
    Leaf.Template.registerTag "component:#{name}", ComponentView

  @get: (name) ->
    name = @regulateName name
    Leaf.Component.components[name]

  @unregister: (name) ->
    name = @regulateName name
    @components[name] = undefined
    Leaf.Template.unregisterTag "component:#{name}"

  @reset: ->
    @unregister name for name in _.keys(@components)


#  Error
#-----------------------------------------------
class NoNameAttributeWithComponentTagError extends Leaf.Error
class ComponentNameMustBeConstantError extends Leaf.Error
class NoPolyBindingWithPolymorphicComponentTagError extends Leaf.Error
class UndefinedComponentTagError extends Leaf.Error
class ComponentClassNotFoundError extends Leaf.Error


#  Component view
#-----------------------------------------------
class ComponentView

  @structure: true

  @create: (node, $marker, $parent, obj) ->
    view = new Leaf.Template.DOMGenerator()

    binder = new Leaf.Template.Binder obj
    bindingObj = binder.getBindingObject node.localeBindings
    tree = Leaf.Component.get node.name

    unless tree
      throw new UndefinedComponentTagError "<#{node.name}>"

    view.init tree, bindingObj

    $el = view.getDOM()

    if Leaf.hasApp()
      klass = Leaf.getComponentClassFor node.name

      unless klass
        throw new ComponentClassNotFoundError node.name

      view = new klass $el
      view.render $marker


#  Component def tag
#-----------------------------------------------
Leaf.Template.registerTag 'component',
  structure: true

  open: (node, parent) ->
    { name } = node.localeBindings

    unless name
      throw new NoNameAttributeWithComponentTagError()

    unless name.raw
      throw new ComponentNameMustBeConstantError()

    Leaf.Component.register name.rawValue, node


Leaf.Template.registerTag 'component:poly',
  structure: true

  open: (node, parent) ->
    unless node.localeBindings.poly
      throw new NoPolyBindingWithPolymorphicComponentTagError()

  create: (node, $marker, $parent, obj) ->
    binder = new Leaf.Template.Binder obj
    poly = binder.getBindingValue node.localeBindings.poly

    node.name = "component:#{Leaf.Component.regulateName poly}"
    ComponentView.create node, $marker, $parent, obj

