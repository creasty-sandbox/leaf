
describe 'Leaf.Event', ->

  it 'should be defined', ->
    expect(Leaf.Event).toBeDefined()

  it 'should create instance', ->
    ev = new Leaf.Event()
    expect(ev).not.toBeNull()
    expect(ev.constructor).toBe Leaf.Event


describe 'event', ->

  beforeEach ->
    @localObj = {}
    @ev = new Leaf.Event @localObj


  describe '#on(eventName, handler)', ->

    it 'should register an event handler', ->
      called = []

      @ev.on 'test', -> called.push 1
      @ev.on 'test', -> called.push 2
      @ev.trigger 'test'

      expect(called).toEqual [1, 2]


  describe '#off(eventName, handler)', ->

    it 'should unsubscribe the event handler', ->
      called = []

      @ev.on 'test', -> called.push 1

      handler = -> called.push 2
      @ev.on 'test', handler
      @ev.off 'test', handler

      @ev.trigger 'test'

      expect(called).toEqual [1]


  describe '#one(eventName, handler)', ->

    it 'should register an event handler that will fire only once', ->
      called = 0

      @ev.one 'test', -> ++called

      @ev.trigger 'test' for i in [0...3]

      expect(called).toEqual 1


  it 'should maintain event subscriptions among instances for the same object', ->
    e1 = new Leaf.Event @localObj
    e2 = new Leaf.Event @localObj

    called = []

    e1.on 'test', -> called.push 'e1'
    e2.on 'test', -> called.push 'e2'

    @ev.trigger 'test'

    expect(called).toEqual ['e1', 'e2']

