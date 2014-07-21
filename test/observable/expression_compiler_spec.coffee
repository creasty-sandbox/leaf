{ chai, expect }   = require '../test_helpers'
ObservableObject   = require '../../src/observable/observable_object'
ExpressionCompiler = require '../../src/observable/expression_compiler'


describe 'new ExpressionCompiler(obj [, scope])', ->

  beforeEach ->
    @obj = new ObservableObject
      foo: 123
      bar: {
        baz: 456
      }

    @scope = new ObservableObject
      foo: 888
      bar: 999

    @compiler = new ExpressionCompiler @obj, @scope


  describe '#scopedExpression(expr)', ->

    it 'should replace local variables in the expression with scoped variables', ->
      expr = 'this.foo + abc'
      res  = 'this.foo + self.abc'

      expect(@compiler.scopedExpression expr).to.equal res

    it 'should skip processing inside regular expression literals', ->
      expr = 'a[1]/b/x/g + /x/g (/x/ g)'
      res  = 'self.a[1]/self.b/self.x/self.g + /x/g (/x/ self.g)'

      expect(@compiler.scopedExpression expr).to.equal res

    it 'should skip processing inside string literals', ->
      expr = 'a + "a \\" \' \\\' a" + \'a " \\" \\\' a\' + a'
      res  = 'self.a + "a \\" \' \\\' a" + \'a " \\" \\\' a\' + self.a'

      expect(@compiler.scopedExpression expr).to.equal res


  describe '#eval(expr)', ->

    it 'should return undefined if the expression has syntastic or runtime errors', ->
      expr = '@@@'

      expect(@compiler.eval expr).not.to.exist

    it 'should return evaluated value of expression', ->
      expr = 'this.foo + this.bar.baz / foo'
      res  = @obj.foo + @obj.bar.baz / @scope.foo

      expect(@compiler.eval expr).to.equal res

