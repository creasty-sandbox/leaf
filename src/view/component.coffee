
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
    .toLowerCase()

  @register: (name, node) ->
    name = @regulateName name
    Leaf.Component.components[name] = node
    Leaf.Template.registerTag name, ComponentView

  @get: (name) ->
    name = @regulateName name
    Leaf.Component.components[name]

  @unregister: (name) ->
    name = @regulateName name
    @components[name] = undefined
    Leaf.Template.unregisterTag name

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

  @create: (viewData) ->
    component = Leaf.Component.get viewData.node.name

    unless component
      throw new UndefinedComponentTagError "<#{viewData.node.name}>"

    klass = Leaf.getComponentClassFor viewData.node.name if Leaf.hasApp()

    unless klass
      Leaf.warn "Undefined view class for <#{viewData.node.name}>"

    klass ?= Leaf.View

    compiler = new Leaf.ExpressionCompiler viewData.controller, viewData.scope
    scope = compiler.evalObject viewData.node.localeBindings

    view = new klass
      tree:       component.contents
      controller: viewData.controller
      scope:      scope

    view.$view.insertAfter viewData.$marker
    view.render()


#  Component def tag
#-----------------------------------------------
Leaf.Template.registerTag 'component',
  structure: true

  open: (node, parent) ->
    { name } = node.attrs

    unless name
      throw new NoNameAttributeWithComponentTagError()

    node.selfClosing = !!node.attrs.block

    Leaf.Component.register name, node

