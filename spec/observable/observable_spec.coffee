
describe 'Leaf.Observable(data)', ->

  it 'should be defined', ->
    expect(Leaf.Observable).toBeDefined()

  it 'should create an instance of ObservableObject hen `data` is an object', ->
    ob = Leaf.Observable {}
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.ObservableObject

  it 'should create an instance of ObservableArray hen `data` is an array', ->
    ob = Leaf.Observable []
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.ObservableArray


