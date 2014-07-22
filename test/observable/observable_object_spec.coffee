{ chai, expect } = require '../test_helpers'
ObservableObject = require '../../src/observable/observable_object'
KeypathEvent     = require '../../src/observable/keypath_event'


describe 'new ObservableObject(data = {})', ->

  beforeEach ->
    @obo = new ObservableObject
      foo: 1
      bar: 2
      computed: -> 3
      dependentComputed: -> @get('foo') + 10
      settableComputed: (val) ->
        if val?
          @set 'bar', val - 20
        else
          @get('bar') + 20
      nested:
        prop1: 4
        prop2: 5
        computed: -> @get('prop1') + 30


  describe '#get(keypath)', ->

    it 'should return property values', ->
      val = @obo.get 'foo'

      expect(val).to.equal 1

    it 'should return computed property values', ->
      val = @obo.get 'computed'

      expect(val).to.equal 3

    it 'should return dependent computed property values', ->
      val = @obo.get 'dependentComputed'

      expect(val).to.equal 11

    it 'should return nested property values', ->
      val = @obo.get 'nested.prop1'

      expect(val).to.equal 4

    it 'should return nested property values using dot operator', ->
      val = @obo.nested.get 'prop1'

      expect(val).to.equal 4

    it 'should return nested computed property values', ->
      val = @obo.get 'nested.computed'

      expect(val).to.equal 34

    it 'should return undefined if property isn\'t found or the keypath is invalid', ->
      val = @obo.get 'should.be.undefined'

      expect(val).to.be.undefined


  describe '#set(keypath, value, options = { notify: true })', ->

    it 'should set property values', ->
      @obo.set 'foo', 100
      val = @obo.get 'foo'

      expect(val).to.equal 100

    it 'should set nested property values', ->
      @obo.set 'nested.prop1', 200
      val = @obo.get 'nested.prop1'

      expect(val).to.equal 200

    it 'should set nested property values using dot operator', ->
      @obo.nested.set 'prop1', 200
      val = @obo.get 'nested.prop1'

      expect(val).to.equal 200

    it 'should set multiple property values by hash', ->
      @obo.set
        foo: 100
        'nested.prop1': 200
        nested:
          prop2: 300

      foo = @obo.get 'foo'
      prop1 = @obo.get 'nested.prop1'
      prop2 = @obo.get 'nested.prop2'

      expect(foo).to.equal 100
      expect(prop1).to.equal 200
      expect(prop2).to.equal 300

    it 'should set computed property values', ->
      @obo.set 'settableComputed', 300
      val1 = @obo.get 'settableComputed'
      val2 = @obo.get 'bar'

      expect(val1).to.equal 300
      expect(val2).to.equal 280


  describe 'Event', ->

    beforeEach ->
      @callback = chai.spy 'observer', => @callbackLastArguments = arguments


    describe '#observe(keypath, callback)', ->

      it 'should call registered observers when setting a property value', ->
        @obo.observe 'foo', @callback

        @obo.set 'foo', 100

        expect(@callback).to.have.been.called()

      it 'should call registered observer with new value', ->
        @obo.observe 'foo', @callback

        @obo.set 'foo', 100

        expect(@callback).to.have.been.called()
        expect(@callbackLastArguments).to.exist
        expect(@callbackLastArguments[0]).to.be.a.instanceof KeypathEvent
        expect(@callbackLastArguments[1]).to.equal 100
        expect(@callbackLastArguments[2]).to.equal 1

      it 'should call registered observers every time when setting a property value', ->
        @obo.observe 'foo', @callback

        @obo.set 'foo', 100
        @obo.set 'foo', 101

        expect(@callback).to.have.been.called.exactly 2

      it 'should call registered observers only once when a property value is the same as last', ->
        @obo.observe 'foo', @callback

        @obo.set 'foo', 100
        @obo.set 'foo', 100

        expect(@callback).to.have.been.called.exactly 1


    describe '#unobserve(keypath, callback)', ->

      it 'should not call unregistered observers', ->
        @obo.observe 'foo', @callback
        @obo.unobserve 'foo', @callback

        @obo.set 'foo', 100

        expect(@callback).not.to.have.been.called()


    describe '#update(keypath)', ->

      it 'should call registered observers immediately', ->
        @obo.observe 'foo', @callback
        @obo.update 'foo'

        expect(@callback).to.have.been.called()


    describe 'Event bubbling on nested properties', ->

      it 'should call event handler on parents when event is fired on children', ->
        @obo.on 'bubble', @callback

        @obo.nested.trigger 'bubble'

        expect(@callback).to.have.been.called()

      it 'should call registered observer on parents when setting children values', ->
        @obo.observe @callback

        @obo.set 'nested.prop1', 200

        expect(@callback).to.have.been.called()


    describe 'Computed properties', ->

      it 'should call registered observers of computed property when settings its dependent property values', ->
        @obo.observe 'dependentComputed', @callback

        @obo.get 'dependentComputed'
        @obo.set 'foo', 100

        expect(@callback).to.have.been.called()
        expect(@callbackLastArguments).to.exist
        expect(@callbackLastArguments[0]).to.be.a.instanceof KeypathEvent
        expect(@callbackLastArguments[1]).to.equal 110
        expect(@callbackLastArguments[2]).to.equal 11

      it 'should call registered observers of dependent properties when setting a computed property value', ->
        callbackComp = chai.spy 'observer of settable computed property'
        callbackDep = chai.spy 'observer of dependent property'

        @obo.observe 'settableComputed', callbackComp
        @obo.observe 'bar', callbackDep

        @obo.set 'settableComputed', 100

        expect(callbackComp).to.have.been.called()
        expect(callbackDep).to.have.been.called()


    describe '#batch(fn)', ->

      it 'should not call registered observers within a batch', ->
        @obo.observe 'foo', @callback

        @obo.batch =>
          @obo.set 'foo', 100
          @obo.set 'foo', 200
          expect(@callback).not.to.have.been.called()


      it 'should call registered observers once after ending batch', ->
        @obo.observe 'foo', @callback

        @obo.batch =>
          @obo.set 'foo', 100
          @obo.set 'foo', 200

        expect(@callback).to.have.been.called.exactly 1


  describe 'Cloning', ->

    beforeEach ->
      @callback = chai.spy 'observer'


    describe '#clone()', ->

      beforeEach ->
        @clone = @obo.clone()

      it 'should create new instance of ObservableObject', ->
        expect(@clone).to.be.an.instanceof ObservableObject

      it 'every properties of original should be readable from a clone', ->
        expect(@clone.foo).to.equal @obo.foo
        expect(@clone.dependentComputed).to.equal @obo.dependentComputed
        expect(@clone.nested.prop1).to.equal @obo.nested.prop1


    describe '#syncedClone()', ->

      beforeEach ->
        @clone = @obo.syncedClone()
        @callbackOriginal = chai.spy 'observer on original'
        @callbackClone = chai.spy 'observer on clone'

      it 'should create new instance of ObservableObject', ->
        expect(@clone).to.be.an.instanceof ObservableObject

      it 'every properties of original should be readable from a clone', ->
        expect(@clone.foo).to.equal @obo.foo
        expect(@clone.dependentComputed).to.equal @obo.dependentComputed
        expect(@clone.nested).to.exist
        expect(@clone.get 'nested.prop1').to.equal @obo.nested.prop1


      describe 'Event delegates', ->
        it 'should delegate events to clone', ->
          @obo.observe 'foo', @callbackOriginal
          @clone.observe 'foo', @callbackClone

          @clone.foo = 123

          expect(@clone.foo).to.equal 123
          expect(@obo.foo).to.equal 123
          expect(@callbackOriginal).to.have.been.called()
          expect(@callbackClone).to.have.been.called()

        it 'should remove delegation and set value with `removeDelegation` option', ->
          @obo.observe 'foo', @callbackOriginal
          @clone.observe 'foo', @callbackClone

          @clone.set 'foo', 123, withoutDelegation: true

          expect(@clone.foo).to.equal 123
          expect(@obo.foo).to.equal 1
          expect(@callbackOriginal).not.to.have.been.called()
          expect(@callbackClone).to.have.been.called()

