{ chai, expect }    = require '../test_helpers'
Observable          = require '../../src/observable'
KeypathEventTracker = require '../../src/observable/keypath_event_tracker'


describe 'new KeypathEventTracker(obj, event)', ->

  beforeEach ->
    @obj = Observable.make
      a:
        b:
          c:
            foo: 1
        z:
          bar: 2


  describe '#track(fn)', ->

    it 'should return keypaths that are activated by the event', ->
      tracker = new KeypathEventTracker @obj, 'get'

      keypaths = tracker.track =>
        @obj.a
        @obj.a.b.c
        @obj.a.z

      expect(keypaths).to.eql ['a', 'a.b.c', 'a.z']

