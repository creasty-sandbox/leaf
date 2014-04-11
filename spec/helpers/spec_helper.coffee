
jasmine.CATCH_EXCEPTIONS = false

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


customMatchers =
  toHaveContents: (util, customEqualityTesters) ->
    compare: (actual, expected) -> pass: toHaveContents actual, expected


beforeEach ->
  flag = false
  spy = (name) -> jasmine.createSpy(name).and.callFake -> flag = true

  @done = spy 'Async done'
  @fail = spy 'Async fail'
  @stop = spy 'Async stop'

  @async = (fn) ->
    waitsFor -> flag
    runs fn

  jasmine.addMatchers customMatchers

