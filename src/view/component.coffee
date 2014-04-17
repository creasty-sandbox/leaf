
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

  @create: (viewData) ->
    tree = Leaf.Component.get viewData.node.name

    unless tree
      throw new UndefinedComponentTagError "<#{viewData.node.name}>"

    klass =
      if Leaf.hasApp()
        Leaf.getComponentClassFor viewData.node.name
      else
        Leaf.View

    unless klass
      throw new ComponentClassNotFoundError viewData.node.name

    compiler = new Leaf.ExpressionCompiler viewData.controller, viewData.scope
    scope = compiler.evalObject viewData.node.localeBindings

    view = new klass
      tree: tree
      controller: viewData.controller
      scope: scope

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

    Leaf.Component.register name, node


Leaf.Template.registerTag 'component:poly',
  structure: true

  open: (node, parent) ->
    unless node.localeBindings.poly
      throw new NoPolyBindingWithPolymorphicComponentTagError()

  create: (viewData) ->
    poly = viewData.scope.get 'poly'
    viewData.node.name = "component:#{Leaf.Component.regulateName poly}"
    ComponentView.create viewData

