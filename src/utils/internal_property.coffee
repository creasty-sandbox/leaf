class InternalProperty

  _id = 0

  constructor: (@obj, @ctx) ->
    @id = (ctx.__internalPropertyObjectID ?= ++_id)

  getInternalName: (prop) -> "__internal_property_#{@id}_#{prop}"

  get: (prop) -> @obj[@getInternalName(prop)]
  set: (prop, data) -> @obj[@getInternalName(prop)] = data
  iset: (prop, data) -> @obj[@getInternalName(prop)] ?= data


internalProperty = (obj, ctx) -> new InternalProperty obj, ctx


module.exports = internalProperty
