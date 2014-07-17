
describe 'Leaf.Event', ->

  it 'should be defined', ->
    expect(Leaf.Event).toBeDefined()

  it 'should create instance', ->
    ev = new Leaf.Event()
    expect(ev).not.toBeNull()
    expect(ev.constructor).toBe Leaf.Event

