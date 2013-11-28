
describe 'Rivets.binders', ->

  context = null

  beforeEach ->
    context = publish: (->)

  describe 'value', ->

    el = null

    beforeEach ->
      el = document.createElement 'input'

    it 'unbinds the same bound function', ->
      boundFn = null

      spyOn(el, 'addEventListener').andCallFake (event, fn) ->
        boundFn = fn

      rivets.binders.value.bind.call context, el

      spyOn(el, 'removeEventListener').andCallFake (event, fn) ->
        expect(fn).toBe boundFn

      rivets.binders.value.unbind.call context, el

