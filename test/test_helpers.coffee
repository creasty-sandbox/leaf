chai  = require 'chai'
spies = require 'chai-spies'

chai.use spies

module.exports =
  chai:   chai
  expect: chai.expect
