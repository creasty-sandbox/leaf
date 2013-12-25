
class Leaf

  develop: true

  log: (args...) ->
    return unless @develop
    msg = ['[Leaf] Log:', args...]
    console.log msg...

  warn: (args...) ->
    return unless @develop
    msg = ['[Leaf] Warn:', args...]
    console.error msg...


# Framework namespace
window.Leaf = new Leaf()

