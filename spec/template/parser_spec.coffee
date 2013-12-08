
describe 'Leaf.Template.Parser', ->

  it 'should be defined', ->
    expect(Leaf.Template.Parser).toBeDefined()

  it 'should create instance', ->
    pr = new Leaf.Template.Parser()
    expect(pr).not.toBeNull()
    expect(pr.constructor).toBe Leaf.Template.Parser


describe 'parser', ->


