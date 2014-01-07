
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

  mixin: (to, mixins...) ->
    for mixin in mixins
      continue unless _.isPlainObject mixin

      to[key] = value for own key, value of mixin when key != 'prototype'
      to::[key] = value for own key, value of mixin:: ? {}

    to


# Framework namespace
window.Leaf = new Leaf()

