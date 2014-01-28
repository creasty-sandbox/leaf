
# jasmine.CATCH_EXCEPTIONS = false

beforeEach ->
  Leaf.develop = true if Leaf?

  flag = false
  spy = (name) -> jasmine.createSpy(name).andCallFake -> flag = true

  @done = spy 'Async done'
  @fail = spy 'Async fail'
  @stop = spy 'Async stop'

  @async = (fn) ->
    waitsFor -> flag
    runs fn

  toString = (o) -> Object::toString.call o

  toHaveContents = (a, b) ->
    if toString(a) != toString(b)
      false
    else if b && b.constructor == Array
      a.length == b.length && b.every (_, i) -> toHaveContents a[i], b[i]
    else if b && b.constructor == Object
      return false unless Object.keys(a).length == Object.keys(b).length
      return false for key, val of b when !toHaveContents a[key], val
      true
    else
      a == b

  @addMatchers
    toHaveContents: (expected) -> toHaveContents @actual, expected

