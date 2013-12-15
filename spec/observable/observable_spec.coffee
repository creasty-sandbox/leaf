
describe 'Leaf.Observable(data)', ->

  it 'should be defined', ->
    expect(Leaf.Observable).toBeDefined()

  it 'should create an instance when `data` is not given', ->
    ob = new Leaf.Observable()
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.Observable

  it 'should create an instance of ObservableObject when `data` is an object', ->
    ob = new Leaf.Observable {}
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.ObservableObject

  it 'should create an instance of ObservableArray when `data` is an array', ->
    ob = new Leaf.Observable []
    expect(ob).not.toBeNull()
    expect(ob.constructor).toBe Leaf.ObservableArray


