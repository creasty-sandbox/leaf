
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
    if b && b.constructor == Array
      a.length == b.length && JSON.stringify(a) == JSON.stringify(b)
    else if b && b.constructor == Object
      return false if Object.keys(a).length == Object.keys(b).length
      for key, val of b
        if !a[key]? || !toHaveContents a[key], val
          return false
      true
    else
      a == b

  @addMatchers
    toHaveContents: (expected) ->
      toHaveContents @actual, expected

