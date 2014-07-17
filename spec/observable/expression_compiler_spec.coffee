
describe 'new Leaf.ExpressionCompiler(obj [, scope])', ->

  beforeEach ->
    @obj = new Leaf.ObservableObject
      foo: 123
      bars: [
        { bar: 456 }
      ]
      baz: {
        abc: 789
      }

    @scope = new Leaf.ObservableObject
      foo: 888
      bar: 999

    @compiler = new Leaf.ExpressionCompiler @obj, @scope


  describe '#scopedExpression(expr)', ->

    it 'should replace local variables in the expression with scoped variables', ->
      expr = 'this.foo + abc'
      res  = 'this.foo + self.abc'

      expect(@compiler.scopedExpression expr).toEqual res

    it 'should skip processing inside regular expression literals', ->
      expr = 'a[1]/b/x/g + /x/g (/x/ g)'
      res  = 'self.a[1]/self.b/self.x/self.g + /x/g (/x/ self.g)'

      expect(@compiler.scopedExpression expr).toEqual res

    it 'should skip processing inside string literals', ->
      expr = 'a + "a \\" \' \\\' a" + \'a " \\" \\\' a\' + a'
      res  = 'self.a + "a \\" \' \\\' a" + \'a " \\" \\\' a\' + self.a'

      expect(@compiler.scopedExpression expr).toEqual res


  describe '#eval(expr)', ->

    it 'should return undefined if the expression has syntastic or runtime errors', ->
      expr = '@@@'

      expect(@compiler.eval expr).not.toBeDefined()

    it 'should return evaluated value of expression', ->
      expr = 'this.foo + this.bars[0].bar / foo'
      res  = @obj.foo + @obj.bars[0].bar / @scope.foo

      expect(@compiler.eval expr).toBe res


  describe '#bind(expr, routine)', ->

    it 'should invoke a routine function immediately with the result', ->
      result = null

      @compiler.bind 'this.foo + 1', (r) -> result = r

      expect(result).toBe @obj.foo + 1

    it 'should invoke a routine function when the value of the object has been updated', ->
      result = null

      @compiler.bind 'this.foo + 1', (r) -> result = r

      @obj.foo = 99

      expect(result).toBe @obj.foo + 1


  describe '#evalObject(pairs)', ->

    beforeEach ->
      obj =
        a: 'this.foo + foo'
        b: 'bar - this.baz.abc'

      @obo = @compiler.evalObject obj


    it 'should create ObservableObject of binded expressions', ->
      expect(@obo instanceof Leaf.ObservableObject).toBe true
      expect(@obo.a).toBe @obj.foo + @scope.foo
      expect(@obo.b).toBe @scope.bar - @obj.baz.abc

    it 'should call registered observer when dependents of the expressions has been updated', ->
      observerA = jasmine.createSpy 'observer a'
      observerB = jasmine.createSpy 'observer b'

      @obo.observe 'a', observerA
      @obo.observe 'b', observerB

      @obj.foo = 99

      expect(observerA).toHaveBeenCalled()
      expect(@obo.a).toBe @obj.foo + @scope.foo

      @scope.bar = 99

      expect(observerB).toHaveBeenCalled()
      expect(@obo.b).toBe @scope.bar - @obj.baz.abc

