_ = require 'lodash'


bindParams = (str, args...) ->
  if _.isObject args[0]
    fn = (_0, name) -> args[0][name] ? _0
  else
    i = 0
    fn = (_0, name) -> args[i++] ? _0

  str.replace /:(\w+)/g, fn


module.exports = bindParams
