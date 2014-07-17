
describe 'Leaf.EventEmitter', ->

  it 'should be defined', ->
    expect(Leaf.EventEmitter).toBeDefined()

  it 'should create instance', ->
    emitter = new Leaf.EventEmitter()
    expect(emitter).not.toBeNull()
    expect(emitter.constructor).toBe Leaf.EventEmitter


describe 'eventEmitter', ->

  beforeEach ->
    @localObj = {}
    @emitter = new Leaf.EventEmitter @localObj


  describe '#on(eventName, handler)', ->

    it 'should register an event handler', ->
      called = []

      @emitter.on 'test', -> called.push 1
      @emitter.on 'test', -> called.push 2
      @emitter.trigger 'test'

      expect(called).toEqual [1, 2]


  describe '#off(eventName, handler)', ->

    it 'should unsubscribe the event handler', ->
      called = []

      @emitter.on 'test', -> called.push 1

      handler = -> called.push 2
      @emitter.on 'test', handler
      @emitter.off 'test', handler

      @emitter.trigger 'test'

      expect(called).toEqual [1]


  describe '#once(eventName, handler)', ->

    it 'should register an event handler that will fire only once', ->
      called = 0

      @emitter.once 'test', -> ++called

      @emitter.trigger 'test' for i in [0...3]

      expect(called).toEqual 1


  it 'should maintain event subscriptions among instances for the same object', ->
    e1 = new Leaf.EventEmitter @localObj
    e2 = new Leaf.EventEmitter @localObj

    called = []

    e1.on 'test', -> called.push 'e1'
    e2.on 'test', -> called.push 'e2'

    @emitter.trigger 'test'

    expect(called).toEqual ['e1', 'e2']

