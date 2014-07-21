{ chai, expect } = require '../test_helpers'
ObservableObject = require '../../src/observable/observable_object'
Binder           = require '../../src/observable/binder'


describe 'new Binder(obj [, scope])', ->

  beforeEach ->
    @obj = new ObservableObject
      foo: 123
      bar: {
        baz: 456
      }

    @scope = new ObservableObject
      foo: 888
      bar: 999

    @binder = new Binder @obj, @scope


  describe '#bind(expr, routine)', ->

    it 'should invoke a routine function immediately with the result', ->
      result = null

      @binder.bind 'this.foo + 1', (r) -> result = r

      expect(result).to.equal @obj.foo + 1

    it 'should invoke a routine function when the value of the object has been updated', ->
      result = null

      @binder.bind 'this.foo + 1', (r) -> result = r

      @obj.foo = 99

      expect(result).to.equal @obj.foo + 1


  describe '#createBindedValueObject(pairs)', ->

    beforeEach ->
      obj =
        a: 'this.foo + foo'
        b: 'bar - this.bar.baz'

      @obo = @binder.createBindedValueObject obj


    it 'should create ObservableObject of binded expressions', ->
      expect(@obo).to.be.an.instanceof ObservableObject
      expect(@obo.a).to.equal @obj.foo + @scope.foo
      expect(@obo.b).to.equal @scope.bar - @obj.bar.baz

    it 'should call registered observer when dependents of the expressions has been updated', ->
      observerA = chai.spy 'observer a'
      observerB = chai.spy 'observer b'

      @obo.observe 'a', observerA
      @obo.observe 'b', observerB

      @obj.foo = 99

      expect(observerA).to.have.been.called()
      expect(@obo.a).to.equal @obj.foo + @scope.foo

      @scope.bar = 99

      expect(observerB).to.have.been.called()
      expect(@obo.b).to.equal @scope.bar - @obj.bar.baz


