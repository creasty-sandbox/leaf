
class ArrayDiffPatch

  MARK_DELETION  = '-'
  MARK_ADDITION  = '+'
  MARK_NONE      = '='

  getClass: -> @constructor

  indexMap: (list) ->
    map = {}

    list.forEach (v, i) ->
      map[v] ?= []
      map[v].push i

    map

  longestCommonSubsequences: (before, after) ->
    result =
      startBefore: 0
      startAfter: 0
      overlapLength: 0

    previous = []

    map = @indexMap before

    after.forEach (a, ia) ->
      overlap = []

      return unless map[a]

      map[a].forEach (ib) ->
        len = ((ib && previous[ib - 1]) || 0) + 1
        overlap[ib] = len

        if len > result.overlapLength
          result.overlapLength = len
          result.startBefore = ib - len + 1
          result.startAfter = ia - len + 1

      previous = overlap

    result

  diff: (before, after) ->
    {
      startBefore
      startAfter
      overlapLength
    } = @longestCommonSubsequences before, after

    unless overlapLength
      removed = before.map (v) -> [MARK_DELETION, v]
      added = after.map (v) -> [MARK_ADDITION, v]
      return [removed..., added...]

    beforeLeft = before[0...startBefore]
    afterLeft = after[0...startAfter]

    equal = after[startAfter...startAfter + overlapLength].map (v) -> [MARK_NONE, v]

    beforeRight = before[startBefore + overlapLength..]
    afterRight = after[startAfter + overlapLength..]

    _.union @diff(beforeLeft, afterLeft), equal, @diff(beforeRight, afterRight)

  createPatch: (method, index, element) -> { method, index, element }

  getPatch: (before, after) ->
    diff = @diff before, after
    patch = []
    index = 0

    diff.forEach (d) =>
      switch d[0]
        when MARK_NONE
          ++index
        when MARK_DELETION
          patch.push @createPatch('removeAt', index, d[1])
        when MARK_ADDITION
          patch.push @createPatch('insertAt', index, d[1])
          ++index

    patch


Leaf.ArrayDiffPatch = new ArrayDiffPatch()

