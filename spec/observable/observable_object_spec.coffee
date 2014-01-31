
describe 'Leaf.ObservableObject', ->

  it 'should be defined', ->
    expect(Leaf.ObservableObject).toBeDefined()

  it 'should create an instance', ->
    ob = new Leaf.ObservableObject()
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.ObservableObject


describe 'observableObject', ->

  beforeEach ->
    @obo = new Leaf.ObservableObject
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

      expect(val).toBe 1

    it 'should return computed property values', ->
      val = @obo.get 'computed'

      expect(val).toBe 3

    it 'should return dependent computed property values', ->
      val = @obo.get 'dependentComputed'

      expect(val).toBe 11

    it 'should return nested property values', ->
      val = @obo.get 'nested.prop1'

      expect(val).toBe 4

    it 'should return nested property values using dot operator', ->
      val = @obo.nested.get 'prop1'

      expect(val).toBe 4

    it 'should return nested computed property values', ->
      val = @obo.get 'nested.computed'

      expect(val).toBe 34

    it 'should return undefined if property isn\'t found or the keypath is invalid', ->
      val = @obo.get 'should.be.undefined'

      expect(val).toBe undefined


  describe '#set(keypath, value, options = { notify: true })', ->

    it 'should set property values', ->
      @obo.set 'foo', 100
      val = @obo.get 'foo'

      expect(val).toBe 100

    it 'should set nested property values', ->
      @obo.set 'nested.prop1', 200
      val = @obo.get 'nested.prop1'

      expect(val).toBe 200

    it 'should set nested property values using dot operator', ->
      @obo.nested.set 'prop1', 200
      val = @obo.get 'nested.prop1'

      expect(val).toBe 200

    it 'should set multiple property values by hash', ->
      @obo.set
        foo: 100
        'nested.prop1': 200
        nested:
          prop2: 300

      foo = @obo.get 'foo'
      prop1 = @obo.get 'nested.prop1'
      prop2 = @obo.get 'nested.prop2'

      expect(foo).toBe 100
      expect(prop1).toBe 200
      expect(prop2).toBe 300

    it 'should set computed property values', ->
      @obo.set 'settableComputed', 300
      val1 = @obo.get 'settableComputed'
      val2 = @obo.get 'bar'

      expect(val1).toBe 300
      expect(val2).toBe 280


  describe '#observe(keypath, callback)', ->

    beforeEach ->
      @callback = jasmine.createSpy 'observer'


    it 'should call registered observers when setting a property value', ->
      @obo.observe 'foo', @callback

      @obo.set 'foo', 100

      expect(@callback).toHaveBeenCalled()

    it 'should call registered observer with new value', ->
      @obo.observe 'foo', @callback

      @obo.set 'foo', 100

      expect(@callback).toHaveBeenCalledWith 100, @obo.toLeafID(), 'foo'

    it 'should call registered observers every time when setting a property value', ->
      n = 0
      callback = jasmine.createSpy('observer').andCallFake -> ++n

      @obo.observe 'foo', callback

      @obo.set 'foo', 100
      @obo.set 'foo', 100

      expect(callback).toHaveBeenCalled()
      expect(n).toBe 2


    describe '#unobserve(keypath, callback)', ->

      it 'should not call unregistered observers', ->
        @obo.observe 'foo', @callback
        @obo.unobserve 'foo', @callback

        @obo.set 'foo', 100

        expect(@callback).not.toHaveBeenCalled()


    describe '#update(keypath)', ->

      it 'should call registered observers immediately', ->
        @obo.observe 'foo', @callback
        @obo.update 'foo'


    describe 'Event bubbling on nested properties', ->

      it 'should call registered observer of parent properties when setting children values', ->
        @obo.observe 'nested', @callback

        @obo.set 'nested.prop1', 200, bubbling: true

        expect(@callback).toHaveBeenCalled()


    describe 'Computed properties', ->

      it 'should call registered observers of computed property when settings its dependent property values', ->
        @obo.observe 'dependentComputed', @callback

        @obo.get 'dependentComputed'
        @obo.set 'foo', 100

        expect(@callback).toHaveBeenCalledWith 110, @obo.toLeafID(), 'dependentComputed'

      it 'should call registered observers of dependent properties when setting a computed property value', ->
        callbackComp = jasmine.createSpy 'observer of settable computed property'
        callbackDep = jasmine.createSpy 'observer of dependent property'

        @obo.observe 'settableComputed', callbackComp
        @obo.observe 'bar', callbackDep

        @obo.set 'settableComputed', 100

        expect(callbackComp).toHaveBeenCalled()
        expect(callbackDep).toHaveBeenCalled()


    describe 'Batch: #beginBatch(), #endBatch()', ->

      it 'should not call registered observers within a batch', ->
        @obo.observe 'foo', @callback

        @obo.beginBatch()
        @obo.set 'foo', 100
        @obo.set 'foo', 200

        expect(@callback).not.toHaveBeenCalled()

      it 'should call registered observers once after ending batch', ->
        n = 0
        callback = jasmine.createSpy('observer').andCallFake -> ++n
        @obo.observe 'foo', callback

        @obo.beginBatch()
        @obo.set 'foo', 100
        @obo.set 'foo', 200

        expect(callback).not.toHaveBeenCalled()

