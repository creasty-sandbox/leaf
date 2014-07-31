_id = 0

internalObjectData = (obj, ctx) ->
  id = (ctx.__internal_object_data_context_id ?= ++_id)
  obj["__internal_object_data_#{id}"] ?= {}


module.exports = internalObjectData
