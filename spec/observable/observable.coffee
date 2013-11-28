
describe 'Observable', ->

  observableObj = null

  beforeEach ->
    observableObj = new Observable
      foo: 1
      bar: 2
      computed: -> 3
      dependentComputed: -> @get('foo') + 10
      settableComputed: (val) ->
        if val?
          @set 'bar', val - 20
        else
          @get('bar') + 20

      ary: [1, 2, 3]
      nested:
        prop: 4
        computed: -> @get('bar') + 30
        obj:
          prop: 5


  describe '#get(keypath)', ->

    it 'should return property values', ->
      val = observableObj.get 'foo'

      expect(val).toBe 1

    it 'should return computed property values', ->
      val = observableObj.get 'computed'

      expect(val).toBe 3

    it 'should return dependent computed property values', ->
      val = observableObj.get 'dependentComputed'

      expect(val).toBe 11

    it 'should return nested property values', ->
      val = observableObj.get 'nested.prop'

      expect(val).toBe 4

    it 'should return nested property values using dot operator', ->
      val = observableObj.nested.get 'prop'

      expect(val).toBe 4

    it 'should return nested computed property values', ->
      val = observableObj.get 'nested.computed'

      expect(val).toBe 34

    it 'should return undefined if property isn\'t found or the keypath is invalid', ->
      val = observableObj.get 'should.be.undefined'

      expect(val).toBe undefined


  describe '#set(keypath, value, notify = true)', ->

    it 'should set property values', ->
      observableObj.set 'foo', 100
      val = observableObj.get 'foo'

      expect(val).toBe 100

    it 'should set nested property values', ->
      observableObj.set 'nested.prop', 200
      val = observableObj.get 'nested.prop'

      expect(val).toBe 200

    it 'should set nested property values using dot operator', ->
      observableObj.nested.set 'prop', 200
      val = observableObj.get 'nested.prop'

      expect(val).toBe 200

    it 'should set computed property values', ->
      observableObj.set 'settableComputed', 300
      val1 = observableObj.get 'settableComputed'
      val2 = observableObj.get 'bar'

      expect(val1).toBe 300
      expect(val2).toBe 280


    describe 'Observable Array', ->

