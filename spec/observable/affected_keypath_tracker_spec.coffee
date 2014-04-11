
describe 'Leaf.AffectedKeypathTracker', ->

  beforeEach ->
    @obj = new Leaf.ObservableObject
      a:
        b:
          c:
            foo: 1
        z:
          bar: 2


  describe '#getAffectedKeypaths()', ->

    it 'should return keypaths that are affected by a specific event', ->
      tracker = new Leaf.AffectedKeypathTracker @obj, 'get'

      @obj.a
      @obj.a.b.c
      @obj.a.z

      expect(tracker.getAffectedKeypaths()).toHaveContents ['a', 'a.b.c', 'a.z']


