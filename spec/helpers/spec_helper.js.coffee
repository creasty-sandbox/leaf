
# jasmine.CATCH_EXCEPTIONS = false

beforeEach ->
  flag = false
  spy = (name) -> jasmine.createSpy(name).andCallFake -> flag = true

  @done = spy 'Async done'
  @fail = spy 'Async fail'
  @stop = spy 'Async stop'

  @async = (fn) ->
    waitsFor -> flag
    runs fn

  toHaveContents = (a, b) ->
    if a == b
      true
    else if b && b.constructor == Array
      a.length == b.length && b.every (_, i) -> toHaveContents a[i], b[i]
    else if b && b.constructor == Object
      return false unless Object.keys(a).length == Object.keys(b).length
      for key, val of b
        if !a[key]? && !toHaveContents a[key], val
          return false
      true
    else
      false

  @addMatchers
    toHaveContents: (expected) -> toHaveContents @actual, expected

