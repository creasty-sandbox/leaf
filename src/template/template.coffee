
class Leaf.Template

  @customTags:
    resets: []
    openOthers: []
    closeOthers: []
    opens:  {}
    closes: {}

  @customAttrs: []

  @registerTag: (name, def) ->
    @customTags.resets.push def.reset if def.reset
    @customTags.openOthers.push { tag: name, fn: def.openOther } if def.openOther
    @customTags.closeOthers.push { tag: name, fn: def.closeOther } if def.closeOther
    @customTags.opens[name] = def.open if def.open
    @customTags.closes[name] = def.close if def.close

