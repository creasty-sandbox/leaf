
describe 'new Leaf.ViewArray($head)', ->

  createItemView = (i) ->
    new Leaf.View element: $('<div/>').addClass "item item-#{i}"


  beforeEach ->
    @$container = $ '<div/>'
    @$begin = $ '<div class="begin" />'
    @$end = $ '<div class="end" />'

    @$container.append @$begin
    @$container.append @$end

    @viewArray = new Leaf.ViewArray @$begin


  describe '#push(views...)', ->

    it 'should add one or more views to the end of the view array', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      expect(@viewArray._views).toHaveContents [v1, v2, v3]

      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 3
      expect($items.eq(0)).toEqual '.item-1'
      expect($items.eq(1)).toEqual '.item-2'
      expect($items.eq(2)).toEqual '.item-3'

    it 'should return the new length of the view array', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      len = @viewArray.push v1, v2, v3

      expect(len).toBe @viewArray.size()


  describe '#pop()', ->

    it 'should remove the last element from the view array', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      @viewArray.pop()

      expect(@viewArray._views).toHaveContents [v1, v2]

      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 2
      expect($items.eq(0)).toEqual '.item-1'
      expect($items.eq(1)).toEqual '.item-2'
      expect(@$container).not.toContainElement '.item-3'

    it 'should return the view that is removed', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      view = @viewArray.pop()

      expect(view).toBe v3


  describe '#unshift(views...)', ->

    it 'should add one or more elements to the front of the view array', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1

      @viewArray.unshift v2, v3

      expect(@viewArray._views).toHaveContents [v2, v3, v1]
      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 3
      expect($items.eq(0)).toEqual '.item-2'
      expect($items.eq(1)).toEqual '.item-3'
      expect($items.eq(2)).toEqual '.item-1'

    it 'should return the new length of the array', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      len = @viewArray.unshift v1, v2, v3

      expect(len).toBe @viewArray.size()

  describe '#shift()', ->

    it 'should remove the first element from the view array', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      @viewArray.shift()

      expect(@viewArray._views).toHaveContents [v2, v3]

      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 2
      expect($items.eq(0)).toEqual '.item-2'
      expect($items.eq(1)).toEqual '.item-3'
      expect(@$container).not.toContainElement '.item-1'

    it 'should return the view that is removed', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      view = @viewArray.shift()

      expect(view).toBe v1


  describe '#insertAt(index, views)', ->

    it 'should insert the views at index', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3
      v4 = createItemView 4

      @viewArray.push v1, v2
      @viewArray.insertAt 1, v3, v4

      expect(@viewArray._views).toHaveContents [v1, v3, v4, v2]
      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 4
      expect($items.eq(0)).toEqual '.item-1'
      expect($items.eq(1)).toEqual '.item-3'
      expect($items.eq(2)).toEqual '.item-4'
      expect($items.eq(3)).toEqual '.item-2'

  describe '#removeAt(index)', ->

    it 'should remove the view at index', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      @viewArray.removeAt 1

      expect(@viewArray._views).toHaveContents [v1, v3]
      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 2
      expect($items.eq(0)).toEqual '.item-1'
      expect($items.eq(1)).toEqual '.item-3'
      expect($items).not.toContainElement '.item-2'

  describe '#swap(i, j)', ->

    it 'should swap the view at `i` and `j`', ->
      v1 = createItemView 1
      v2 = createItemView 2
      v3 = createItemView 3

      @viewArray.push v1, v2, v3

      @viewArray.swap 1, 2

      expect(@viewArray._views).toHaveContents [v1, v3, v2]
      $items = @$container.find '.item'

      expect($items).toExist()
      expect($items).toHaveLength 3
      expect($items.eq(0)).toEqual '.item-1'
      expect($items.eq(1)).toEqual '.item-3'
      expect($items.eq(2)).toEqual '.item-2'

