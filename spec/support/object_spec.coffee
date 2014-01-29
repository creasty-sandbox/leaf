
describe 'Object', ->

  describe '#get(key)', ->

    it 'should be defined', ->
      expect(Object::get).toBeDefined()

    it 'should return a property value of object', ->
      obj = a: 123

      expect(obj.get('a')).toBe obj['a']


  describe '#set(key, val)', ->

    it 'should be defined', ->
      expect(Object::set).toBeDefined()

    it 'should set new value to the property of object', ->
      obj = a: 123

      obj.set 'a', 999

      expect(obj['a']).toBe 999

