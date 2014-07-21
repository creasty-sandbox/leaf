console.log   ?= (->)
console.error ?= (->)

debug = (args...) ->
  console.log '[Leaf] Log:', args...

warn = (args...) ->
  console.error '[Leaf] Warn:', args...


module.exports = { debug, warn }
