
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


  @addMatchers
    toHaveContents: (expected) ->
      JSON.stringify(@actual) == JSON.stringify(expected)

