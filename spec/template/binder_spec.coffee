
describe 'Leaf.Template.Binder', ->

  it 'should be defined', ->
    expect(Leaf.Template.Binder).toBeDefined()

  it 'should throw an exception when instaitiate without ObservableObject', ->
    ctx = ->
      new Leaf.Template.Binder {}

    expect(ctx).toThrow()

  it 'should create instance with ObservableObject', ->
    obj = new Leaf.ObservableObject()
    binder = new Leaf.Template.Binder obj

    expect(binder).not.toBeNull()
    expect(binder.constructor).toBe Leaf.Template.Binder


describe 'binder', ->

  beforeEach ->
    @obj = new Leaf.ObservableObject
      foo: 123
      bars: [
        { bar: 456 }
      ]
      baz: {
        abc: 789
      }

    @binder = new Leaf.Template.Binder @obj


  describe '#getFunction(expr, vars)', ->

    it 'should return a function that evaluate `expr` with arguments of `vars`', ->
      fn = @binder.getFunction 'a + b', ['a', 'b']

      expect(_.isFunction(fn)).toBe true

    it 'should return noop function when `expr` has errors and fail creating function', ->
      fn = @binder.getFunction '@@@', []

      expect(fn).toBe _.noop


  describe 'getEvaluator(fn, vars)', ->

    it 'should return an evaluator function that call `fn` function with the values of the object', ->
      expr = 'foo + 1'
      vars = ['foo']

      fn = @binder.getFunction expr, vars
      evaluate = @binder.getEvaluator fn, vars

      expect(_.isFunction(evaluate)).toBe true


    describe 'an evaluator function', ->

      it 'should return the result of `expr`', ->
        expr = 'foo + 1'
        vars = ['foo']

        fn = @binder.getFunction expr, vars
        evaluate = @binder.getEvaluator fn, vars

        expect(evaluate()).toBe 124

      it 'should return empty string if `expr` is invalid', ->
          expr = 'foo.zoo()'
          vars = ['foo']

          fn = @binder.getFunction expr, vars
          evaluate = @binder.getEvaluator fn, vars

          expect(evaluate()).toBe ''


  describe '#getBinder(value)', ->

    beforeEach ->
      @values =
        a: { expr: 'foo + 1', vars: ['foo'] }
        b: { expr: 'bars[0].bar + 10', vars: ['bars'] }
        c: { expr: 'baz.abc + 100', vars: ['baz'] }


    it 'should return a binder function that observes object for update', ->
      bind = @binder.getBinder @values.a

      expect(_.isFunction(bind)).toBe true


    describe 'a binder function', ->

      it 'should invoke a routine function immediately with the result', ->
        bind = @binder.getBinder @values.a

        result = null
        bind (r) -> result = r

        expect(result).toBe 124

      it 'should be invoked when the value of the object has updated', ->
        bind = @binder.getBinder @values.c

        result = null
        bind (r) -> result = r

        @obj.baz.abc = 890

        expect(result).toBe 990


  describe '#getBindingValue(value)', ->

    it 'should return a result value of expression', ->
      value = expr: 'foo + 1', vars: ['foo']
      result = @binder.getBindingValue value

      expect(result).toBe 124


  describe '#getBindingObject(values)', ->

    it 'should return result object of values', ->
      values =
        a: { expr: 'foo + 1', vars: ['foo'] }
        b: { expr: 'bars[0].bar + 10', vars: ['bars'] }
        c: { expr: 'baz.abc + 100', vars: ['baz'] }

      results = @binder.getBindingObject values

      expect(results instanceof Leaf.ObservableObject).toBe true
      expect(results.a).toBe 124
      expect(results.b).toBe 466
      expect(results.c).toBe 889


