
describe 'Leaf.ObservableArray', ->

  it 'should be defined', ->
    expect(Leaf.ObservableArray).toBeDefined()

  it 'should create an instance', ->
    ob = new Leaf.ObservableArray()
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.ObservableArray


describe 'observableArray', ->

  oba = null
  callback = null

  beforeEach ->
    oba = new Leaf.ObservableArray [1, 2, 3]
    callback = jasmine.createSpy 'observer'

  afterEach ->
    oba.unobserve callback


  describe 'Mutator methods', ->

    describe '#push(elements...)', ->

      it 'should add one or more elements to the end of an array', ->
        oba.push 4

        expect(oba.toArray()).toHaveContents [1, 2, 3, 4]

        oba.push 5, 6

        expect(oba.toArray()).toHaveContents [1, 2, 3, 4, 5, 6]

      it 'should return the new length of the array', ->
        expect(oba.length).toBe 3

        len = oba.push 4

        expect(len).toBe 4
        expect(oba.length).toBe 4

      it 'should call registered observers', ->
        oba.observe callback

        oba.push 4

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.push 4

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 3, 4
        ]

        expect(oba.getPatch()).toHaveContents patch


    describe '#pop()', ->

      it 'should remove the last element from an array', ->
        oba.pop()

        expect(oba.toArray()).toHaveContents [1, 2]

      it 'should return the element that is removed', ->
        el = oba.pop()

        expect(el).toBe 3

      it 'should call registered observers', ->
        oba.observe callback

        oba.pop()

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.pop()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 2
        ]

        expect(oba.getPatch()).toHaveContents patch


    describe '#shift()', ->
      it 'should remove the last element from an array', ->
        oba.shift()

        expect(oba.toArray()).toHaveContents [2, 3]

      it 'should return the element that is removed', ->
        el = oba.shift()

        expect(el).toBe 1

      it 'should call registered observers', ->
        oba.observe callback

        oba.shift()

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.shift()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 0
        ]

        expect(oba.getPatch()).toHaveContents patch


    describe '#unshift(elements...)', ->

      it 'should add one or more elements to the front of an array', ->
        oba.unshift 0

        expect(oba.toArray()).toHaveContents [0, 1, 2, 3]

        oba.unshift -2, -1

        expect(oba.toArray()).toHaveContents [-2, -1, 0, 1, 2, 3]

      it 'should return the new length of the array', ->
        expect(oba.length).toBe 3

        len = oba.unshift 0

        expect(len).toBe 4
        expect(oba.length).toBe 4

      it 'should call registered observers', ->
        oba.observe callback

        oba.unshift 0

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.unshift 0

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 0, 0
        ]

        expect(oba.getPatch()).toHaveContents patch


    describe '#sort([compareFunc])', ->

      beforeEach ->
        oba.push -1

      it 'should sort the elements of an array in place', ->
        oba.sort()

        expect(oba.toArray()).toHaveContents [-1, 1, 2, 3]

      it 'should return the array', ->
        ary = oba.sort()

        expect(ary).toBe oba

      it 'should call registered observers', ->
        oba.observe callback

        oba.sort()

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.sort()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 0, -1
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 4
        ]

        expect(oba.getPatch()).toHaveContents patch

    describe '#splice(index [, size [, elements...]])', ->

      it 'should add and/or remove elements from an array', ->
        oba.splice 1, 1, 8, 9

        expect(oba.toArray()).toHaveContents [1, 8, 9, 3]

      it 'should call registered observers', ->
        oba.observe callback

        oba.splice 1, 1, 8, 9

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.splice 1, 1, 8, 9

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 1
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 0, 8
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 1, 9
        ]

        expect(oba.getPatch()).toHaveContents patch


    describe '#reverse()', ->

      it 'should reverse the order of the elements of an array', ->
        oba.reverse()

        expect(oba.toArray()).toHaveContents [3, 2, 1]

      it 'should call registered observers', ->
        oba.observe callback

        oba.reverse()

        expect(callback).toHaveBeenCalled()

      it 'should create diff patch for an operation', ->
        oba.reverse()

        patch = [
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 0
          Leaf.ArrayDiffPatch.createPatch 'removeAt', 0
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 1, 2
          Leaf.ArrayDiffPatch.createPatch 'insertAt', 2, 1
        ]

        expect(oba.getPatch()).toHaveContents patch


  describe 'Accessor methods', ->

    describe '#indexOf(element)', ->

      it 'should return the first index of an element within the array equal to `element`', ->
        expect(oba.indexOf(1)).toBe 0
        expect(oba.indexOf(2)).toBe 1

      it 'should return -1 if none is found', ->
        expect(oba.indexOf(999)).toBe -1


  describe 'Iteration methods', ->

    describe '#forEach(func [, thisObject])', ->

      it 'should call a function for each element in the array', ->
        str = ''

        oba.forEach (v, i) -> str += i + '' + v

        expect(str).toBe '011223'


    describe '#every(func [, thisObject])', ->

      it 'should return true if every element in this array satisfies the provided testing function', ->
        res1 = oba.every (v) -> v > 2
        res2 = oba.every (v, i) -> v > i

        expect(res1).toBe false
        expect(res2).toBe true


    describe '#some(func [, thisObject])', ->

      it 'should return true if at least one element in this array satisfies the provided testing function', ->
        res1 = oba.some (v) -> v > 9
        res2 = oba.some (v) -> v % 2 == 0

        expect(res1).toBe false
        expect(res2).toBe true


    describe '#filter(func [, thisObject])', ->

      it 'should create a new ObservableArray with all of the elements of this array for which the provided filtering function returns true', ->
        res = oba.filter (v) -> v > 1

        expect(res instanceof Leaf.ObservableArray).toBe true
        expect(res.toArray()).toHaveContents [2, 3]


    describe '#map(func [, thisObject])', ->

      it 'should create a new array with the results of calling a provided function on every element in this array', ->
        res = oba.map (v) -> v * 2

        expect(res).toHaveContents [2, 4, 6]


    describe '#reduce(func [, initialValue])', ->

      it 'should apply a function against an accumulator and each value of the array (from left-to-right) as to reduce it to a single value', ->
        res = oba.reduce ((a, b) -> a + b), ''

        expect(res).toBe '123'


    describe '#reduceRight(func)', ->

      it 'should apply a function against an accumulator and each value of the array (from right-to-left) as to reduce it to a single value', ->
        res = oba.reduceRight ((a, b, i) -> console.log a, b, i; a + i * b)

        expect(res).toBe 3 + 1 * 2 + 0 * 1

