{ chai, expect } = require '../test_helpers'
Observable       = require '../../src/observable'
ObservableObject = require '../../src/observable/observable_object'
ObservableArray  = require '../../src/observable/observable_array'


describe 'Observable.make(data)', ->

  it 'should create an instance of ObservableObject hen `data` is an object', ->
    ob = Observable.make {}
    expect(ob).to.be.an.instanceof ObservableObject

  it 'should create an instance of ObservableArray hen `data` is an array', ->
    ob = Observable.make []
    expect(ob).to.be.an.instanceof ObservableArray

