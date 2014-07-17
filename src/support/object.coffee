
class ObjectSupport

  get: (obj, key) -> obj[key]
  set: (obj, key, val) -> obj[key] = val


Leaf.Support.add ObjectSupport

