
describe 'Leaf.Observable', ->

  it 'should be defined', ->
    expect(Leaf.Observable).toBeDefined()

  it 'should create an instance', ->
    ob = new Leaf.Observable()
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.Observable


describe 'observable', ->

  observableObj = null

  beforeEach ->
    observableObj = new Leaf.Observable
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
        prop1: 4
        prop2: 5
        computed: -> @get('prop1') + 30


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
      val = observableObj.get 'nested.prop1'

      expect(val).toBe 4

    it 'should return nested property values using dot operator', ->
      val = observableObj.nested.get 'prop1'

      expect(val).toBe 4

    it 'should return nested computed property values', ->
      val = observableObj.get 'nested.computed'

      expect(val).toBe 34

    it 'should return undefined if property isn\'t found or the keypath is invalid', ->
      val = observableObj.get 'should.be.undefined'

      expect(val).toBe undefined


  describe '#set(keypath, value, options = { notify: true })', ->

    it 'should set property values', ->
      observableObj.set 'foo', 100
      val = observableObj.get 'foo'

      expect(val).toBe 100

    it 'should set nested property values', ->
      observableObj.set 'nested.prop1', 200
      val = observableObj.get 'nested.prop1'

      expect(val).toBe 200

    it 'should set nested property values using dot operator', ->
      observableObj.nested.set 'prop1', 200
      val = observableObj.get 'nested.prop1'

      expect(val).toBe 200

    it 'should set multiple property values by hash', ->
      observableObj.set
        foo: 100
        'nested.prop1': 200
        nested:
          prop2: 300

      foo = observableObj.get 'foo'
      prop1 = observableObj.get 'nested.prop1'
      prop2 = observableObj.get 'nested.prop2'

      expect(foo).toBe 100
      expect(prop1).toBe 200
      expect(prop2).toBe 300

    it 'should set computed property values', ->
      observableObj.set 'settableComputed', 300
      val1 = observableObj.get 'settableComputed'
      val2 = observableObj.get 'bar'

      expect(val1).toBe 300
      expect(val2).toBe 280


  describe '#observe(keypath, callback)', ->

    callback = null

    beforeEach ->
      callback = jasmine.createSpy 'observer'


    it 'should call registered observers when setting a property value', ->
      observableObj.observe 'foo', callback

      observableObj.set 'foo', 100

      expect(callback).toHaveBeenCalled()

    it 'should call registered observer with new value', ->
      observableObj.observe 'foo', callback

      observableObj.set 'foo', 100

      expect(callback).toHaveBeenCalledWith 100

    it 'should call registered observers every time when setting a property value', ->
      n = 0
      callback = jasmine.createSpy('observer').andCallFake -> ++n

      observableObj.observe 'foo', callback

      observableObj.set 'foo', 100
      observableObj.set 'foo', 100

      expect(callback).toHaveBeenCalled()
      expect(n).toBe 2


    describe '#unobserve(keypath, callback)', ->

      it 'should not call unregistered observers', ->
        observableObj.observe 'foo', callback
        observableObj.unobserve 'foo', callback

        observableObj.set 'foo', 100

        expect(callback).not.toHaveBeenCalled()


    describe '#update(keypath)', ->

      it 'should call registered observers immediately', ->
        observableObj.observe 'foo', callback
        observableObj.update 'foo'


    describe 'Event bubbling on nested properties', ->

      it 'should call registered observer of parent properties when setting children values', ->
        observableObj.observe 'nested', callback

        observableObj.set 'nested.prop1', 200, bubbling: true

        expect(callback).toHaveBeenCalled()


    describe 'Computed properties', ->

      it 'should call registered observers of computed property when settings its dependent property values', ->
        observableObj.observe 'dependentComputed', callback

        observableObj.get 'dependentComputed'
        observableObj.set 'foo', 100

        expect(callback).toHaveBeenCalledWith 110

      it 'should call registered observers of dependent properties when setting a computed property value', ->
        callbackComp = jasmine.createSpy 'observer of settable computed property'
        callbackDep = jasmine.createSpy 'observer of dependent property'

        observableObj.observe 'settableComputed', callbackComp
        observableObj.observe 'bar', callbackDep

        observableObj.set 'settableComputed', 100

        expect(callbackComp).toHaveBeenCalled()
        expect(callbackDep).toHaveBeenCalled()


    describe 'Batch: #beginBatch(), #endBatch()', ->

      it 'should not call registered observers within a batch', ->
        observableObj.observe 'foo', callback

        observableObj.beginBatch()
        observableObj.set 'foo', 100
        observableObj.set 'foo', 200

        expect(callback).not.toHaveBeenCalled()

      it 'should call registered observers once after ending batch', ->
        n = 0
        callback = jasmine.createSpy('observer').andCallFake -> ++n
        observableObj.observe 'foo', callback

        observableObj.beginBatch()
        observableObj.set 'foo', 100
        observableObj.set 'foo', 200

        expect(callback).not.toHaveBeenCalled()


    describe 'Array operation', ->

      it 'should call registered observers when updating elements via `push`', ->
        observableObj.observe 'ary', callback

        ary = observableObj.get 'ary'
        ary.push 4

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 3, 4
        ]

        expect(ary.toArray()).toHaveContents [1, 2, 3, 4]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch

      it 'should call registered observers when updating elements via `unshift`', ->
        observableObj.observe 'ary', callback

        ary = observableObj.get 'ary'
        ary.unshift 0

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 0, 4
        ]

        expect(ary.toArray()).toHaveContents [0, 1, 2, 3]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch

      it 'should call registered observers when updating elements via `pop`', ->
        observableObj.observe 'ary', callback

        ary = observableObj.get 'ary'
        ary.pop()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 2
        ]

        expect(ary.toArray()).toHaveContents [1, 2]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch

      it 'should call registered observers when updating elements via `shift`', ->
        observableObj.observe 'ary', callback

        ary = observableObj.get 'ary'
        ary.shift()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 0
        ]

        expect(ary.toArray()).toHaveContents [2, 3]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch

      it 'should call registered observers when updating elements via `sort`', ->
        ary = observableObj.get 'ary'
        ary.push -1

        observableObj.observe 'ary', callback
        ary.sort()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 0, -1
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 4
        ]

        expect(ary.toArray()).toHaveContents [-1, 1, 2, 3]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch

      it 'should call registered observers when updating elements via `reverse`', ->
        observableObj.observe 'ary', callback

        ary = observableObj.get 'ary'
        ary.reverse()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 0
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 0
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 1, 2
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 2, 1
        ]

        expect(ary.toArray()).toHaveContents [3, 2, 1]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch

      it 'should call registered observers when updating elements via `splice`', ->
        observableObj.observe 'ary', callback

        ary = observableObj.get 'ary'
        ary.splice 1, 1, 8, 9

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 1
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 1, 8
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 2, 9
        ]

        expect(ary.toArray()).toHaveContents [1, 8, 9, 3]
        expect(callback).toHaveBeenCalled()
        expect(ary.getPatch()).toHaveContents patch


