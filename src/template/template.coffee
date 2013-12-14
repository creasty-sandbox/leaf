
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

