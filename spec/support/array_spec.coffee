
describe 'Array', ->

  describe '#get(index)', ->

    it 'should be defined', ->
      expect(Array::get).toBeDefined()

    it 'should return a element at index of array', ->
      ary = [1, 1, 2, 3, 5, 8]

      expect(ary.get(4)).toBe ary[4]


  describe '#set(index, element)', ->

    it 'should be defined', ->
      expect(Array::set).toBeDefined()

    it 'should set new element to the index of array', ->
      ary = [1, 1, 2, 3, 5, 8]

      obj.set 4, 999

      expect(obj[4]).toBe 999

