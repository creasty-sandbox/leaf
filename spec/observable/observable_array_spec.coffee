
describe 'new Leaf.ObservableArray(data = [])', ->

  beforeEach ->
    @oba = new Leaf.ObservableArray [1, 2, 3]
    @callback = jasmine.createSpy 'observer'

  afterEach ->
    @oba.unobserve @callback


  describe 'Mutator methods', ->

    describe '#push(elements...)', ->

      it 'should add one or more elements to the end of an array', ->
        @oba.push 4

        expect(@oba.toArray()).toHaveContents [1, 2, 3, 4]

        @oba.push 5, 6

        expect(@oba.toArray()).toHaveContents [1, 2, 3, 4, 5, 6]

      it 'should return the new length of the array', ->
        expect(@oba.length).toBe 3

        len = @oba.push 4

        expect(len).toBe 4
        expect(@oba.length).toBe 4

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.push 4

        expect(@callback).toHaveBeenCalled()


    describe '#pop()', ->

      it 'should remove the last element from an array', ->
        @oba.pop()

        expect(@oba.toArray()).toHaveContents [1, 2]

      it 'should return the element that is removed', ->
        el = @oba.pop()

        expect(el).toBe 3

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.pop()

        expect(@callback).toHaveBeenCalled()


    describe '#unshift(elements...)', ->

      it 'should add one or more elements to the front of an array', ->
        @oba.unshift 0

        expect(@oba.toArray()).toHaveContents [0, 1, 2, 3]

        @oba.unshift -2, -1

        expect(@oba.toArray()).toHaveContents [-2, -1, 0, 1, 2, 3]

      it 'should return the new length of the array', ->
        expect(@oba.length).toBe 3

        len = @oba.unshift 0

        expect(len).toBe 4
        expect(@oba.length).toBe 4

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.unshift 0

        expect(@callback).toHaveBeenCalled()


    describe '#shift()', ->

      it 'should remove the first element from an array', ->
        @oba.shift()

        expect(@oba.toArray()).toHaveContents [2, 3]

      it 'should return the element that is removed', ->
        el = @oba.shift()

        expect(el).toBe 1

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.shift()

        expect(@callback).toHaveBeenCalled()


    describe '#sort([compareFunc])', ->

      beforeEach ->
        @oba.push -1

      it 'should sort the elements of an array in place', ->
        @oba.sort()

        expect(@oba.toArray()).toHaveContents [-1, 1, 2, 3]

      it 'should return the array', ->
        ary = @oba.sort()

        expect(ary).toBe @oba

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.sort()

        expect(@callback).toHaveBeenCalled()


    describe '#splice(index [, size [, elements...]])', ->

      it 'should add and/or remove elements from an array', ->
        @oba.splice 1, 1, 8, 9

        expect(@oba.toArray()).toHaveContents [1, 8, 9, 3]

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.splice 1, 1, 8, 9

        expect(@callback).toHaveBeenCalled()


    describe '#reverse()', ->

      it 'should reverse the order of the elements of an array', ->
        @oba.reverse()

        expect(@oba.toArray()).toHaveContents [3, 2, 1]

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.reverse()

        expect(@callback).toHaveBeenCalled()


    describe '#swap(i, j)', ->

      it 'should swap the elements at `i` and `j`', ->
        @oba.swap 0, 1

        expect(@oba.toArray()).toHaveContents [2, 1, 3]

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.swap 0, 1

        expect(@callback).toHaveBeenCalled()


    describe '#removeAt(index)', ->

      it 'should remove the element at index', ->
        @oba.removeAt 1

        expect(@oba.toArray()).toHaveContents [1, 3]

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.removeAt 1

        expect(@callback).toHaveBeenCalled()


    describe '#insertAt(index, elements)', ->

      it 'should insert the element at index', ->
        @oba.insertAt 1, 99

        expect(@oba.toArray()).toHaveContents [1, 99, 2, 3]

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba.insertAt 1, 99

        expect(@callback).toHaveBeenCalled()


    describe '#_set(index, val, options = {})', ->

      it 'should replace the element at index', ->
        @oba._set 1, 99

        expect(@oba.toArray()).toHaveContents [1, 99, 3]

      it 'should call registered observers', ->
        @oba.observe @callback

        @oba._set 1, 99

        expect(@callback).toHaveBeenCalled()


  describe 'Accessor methods', ->

    describe '#indexOf(element)', ->

      it 'should return the first index of an element within the array equal to `element`', ->
        expect(@oba.indexOf(1)).toBe 0
        expect(@oba.indexOf(2)).toBe 1

      it 'should return -1 if none is found', ->
        expect(@oba.indexOf(999)).toBe -1


  describe 'Iteration methods', ->

    describe '#forEach(func [, thisObject])', ->

      it 'should call a function for each element in the array', ->
        str = ''

        @oba.forEach (v, i) -> str += i + '' + v

        expect(str).toBe '011223'


    describe '#every(func [, thisObject])', ->

      it 'should return true if every element in this array satisfies the provided testing function', ->
        res1 = @oba.every (v) -> v > 2
        res2 = @oba.every (v, i) -> v > i

        expect(res1).toBe false
        expect(res2).toBe true


    describe '#some(func [, thisObject])', ->

      it 'should return true if at least one element in this array satisfies the provided testing function', ->
        res1 = @oba.some (v) -> v > 9
        res2 = @oba.some (v) -> v % 2 == 0

        expect(res1).toBe false
        expect(res2).toBe true


    describe '#filter(func [, thisObject])', ->

      it 'should create a new ObservableArray with all of the elements of this array for which the provided filtering function returns true', ->
        res = @oba.filter (v) -> v > 1

        expect(res instanceof Leaf.ObservableArray).toBe true
        expect(res.toArray()).toHaveContents [2, 3]


    describe '#map(func [, thisObject])', ->

      it 'should create a new array with the results of calling a provided function on every element in this array', ->
        res = @oba.map (v) -> v * 2

        expect(res).toHaveContents [2, 4, 6]


    describe '#reduce(func [, initialValue])', ->

      it 'should apply a function against an accumulator and each value of the array (from left-to-right) as to reduce it to a single value', ->
        res = @oba.reduce ((a, b) -> a + b), ''

        expect(res).toBe '123'


    describe '#reduceRight(func)', ->

      it 'should apply a function against an accumulator and each value of the array (from right-to-left) as to reduce it to a single value', ->
        res = @oba.reduceRight (a, b, i) -> a + i * b

        expect(res).toBe 3 + 1 * 2 + 0 * 1


  describe 'Element detaching', ->

    it 'should remove an element if the element has fired `detach` event', ->
      obj = new Leaf.ObservableObject foo: 1
      ary = new Leaf.ObservableArray [1, obj, 2]

      obj.detach()

      expect(ary.length).toBe 2
      expect(ary.toArray()).toHaveContents [1, 2]


  describe '#sync(handler)', ->

    it 'should sync mutations by handler', ->
      ary1 = new Leaf.ObservableArray()
      ary2 = new Leaf.ObservableArray()

      handler =
        insertAt: (i, element) ->
          ary2.insertAt i, element * 2
        removeAt: (i) ->
          ary2.removeAt i
        swap: (i, j) ->
          ary2.swap i, j

      ary1.observe (e) -> ary1.sync handler

      ary1.push 1

      expect(ary1.toArray()).toHaveContents [1]
      expect(ary2.toArray()).toHaveContents [2]

      ary1.insertAt 1, 2, 3

      expect(ary1.toArray()).toHaveContents [1, 2, 3]
      expect(ary2.toArray()).toHaveContents [2, 4, 6]

      ary1.pop()

      expect(ary1.toArray()).toHaveContents [1, 2]
      expect(ary2.toArray()).toHaveContents [2, 4]

