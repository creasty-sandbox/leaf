
class ArraySupport

  get: (ary, key) -> ary[key]
  set: (ary, key, val) -> ary[key] = val


Leaf.Support.add ArraySupport

