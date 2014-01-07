
class Leaf.Template

  @customTags:
    resets: []
    openOthers: []
    closeOthers: []
    def: {}

  @customAttrs: []

  @registerTag: (name, def) ->
    @customTags.def[name] = def

    @customTags.resets.push name if def.reset
    @customTags.openOthers.push name if def.openOther
    @customTags.closeOthers.push name if def.closeOther

  @unregisterTag: (name) ->
    def = @customTags.def[name] ? {}
    @customTags.def[name] = undefined

    if def.reset && ~(i = @customTags.resets.indexOf name)
      @customTags.resets.splice i, 1

    if def.openOther && ~(i = @customTags.openOthers.indexOf name)
      @customTags.openOthers.splice i, 1

    if def.closeOther && ~(i = @customTags.closeOthers.indexOf name)
      @customTags.closeOthers.splice i, 1

