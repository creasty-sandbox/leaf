chai  = require 'chai'
spies = require 'chai-spies'

chai.use spies

chai.use (chai, utils) ->
  chai.Assertion.addMethod 'datetime', (expected) ->
    actual = @_obj

    new chai.Assertion(actual).to.be.instanceof Date
    new chai.Assertion(expected).to.be.instanceof Date

    # ignore milisecond-order error
    @assert Math.abs(+actual - expected) < 1000,
      'expected #{act} to be #{exp}',
      'expected #{act} to not be #{exp}',
      expected,
      actual


module.exports =
  chai:   chai
  expect: chai.expect
