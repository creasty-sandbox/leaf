{ chai, expect } = require '../test_helpers'
NumberHelper     = require '../../src/supports/number_helper'


describe 'NumberHelper', ->

  describe '::pluralize(num, word [, withNumber = false])', ->

    it 'should return pluralized word', ->
      expect(NumberHelper.pluralize(1, 'book')).to.equal 'book'
      expect(NumberHelper.pluralize(2, 'book')).to.equal 'books'

    it 'should return pluralized word with count with `withNumber`', ->
      expect(NumberHelper.pluralize(2, 'book', true)).to.equal '2 books'


  describe '::ordinalize(num)', ->

    it 'should ordinalize number', ->
      expect(NumberHelper.ordinalize(2)).to.equal '2nd'


  describe '::byte(num)', ->

    it 'should be identical function', ->
      expect(NumberHelper.byte(2)).to.equal 2


  describe '::kilobyte(num)', ->

    it 'should return number multiplied by 1024^1', ->
      expect(NumberHelper.kilobyte(2)).to.equal 2 * Math.pow(1024, 1)


  describe '::megabyte(num)', ->

    it 'should return number multiplied by 1024^2', ->
      expect(NumberHelper.megabyte(2)).to.equal 2 * Math.pow(1024, 2)


  describe '::gigabyte(num)', ->

    it 'should return number multiplied by 1024^3', ->
      expect(NumberHelper.gigabyte(2)).to.equal 2 * Math.pow(1024, 3)


  describe '::terabyte(num)', ->

    it 'should return number multiplied by 1024^4', ->
      expect(NumberHelper.terabyte(2)).to.equal 2 * Math.pow(1024, 4)


  describe '::petabyte(num)', ->

    it 'should return number multiplied by 1024^5', ->
      expect(NumberHelper.petabyte(2)).to.equal 2 * Math.pow(1024, 5)


  describe '::exabyte(num)', ->

    it 'should return number multiplied by 1024^6', ->
      expect(NumberHelper.exabyte(2)).to.equal 2 * Math.pow(1024, 6)


  describe '::second(num)', ->

    it 'should return seconds of number in milisecound', ->
      expect(NumberHelper.second(2)).to.equal 2 * 1000


  describe '::minute(num)', ->

    it 'should return minutes of number in milisecound', ->
      expect(NumberHelper.minute(2)).to.equal 2 * 1000 * 60


  describe '::hour(num)', ->

    it 'should return hours of number in milisecound', ->
      expect(NumberHelper.hour(2)).to.equal 2 * 1000 * 60 * 60


  describe '::day(num)', ->

    it 'should return days of number in milisecound', ->
      expect(NumberHelper.day(2)).to.equal 2 * 1000 * 60 * 60 * 24


  describe '::week(num)', ->

    it 'should return weeks of number in milisecound', ->
      expect(NumberHelper.week(2)).to.equal 2 * 1000 * 60 * 60 * 24 * 7


  describe '::fortnight(num)', ->

    it 'should return fortnights of number in milisecound', ->
      expect(NumberHelper.fortnight(2)).to.equal 2 * 1000 * 60 * 60 * 24 * 7 * 2


  describe '::month(num)', ->

    it 'should return months of number in milisecound', ->
      expect(NumberHelper.month(2)).to.equal 2 * 1000 * 60 * 60 * 24 * 30


  describe '::year(num)', ->

    it 'should return years of number in milisecound', ->
      expect(NumberHelper.year(2)).to.equal 2 * 1000 * 60 * 60 * 24 * 30 * 12


  describe '::since(num [, reference])', ->

    it 'should return a date that milisecounds of number after reference', ->
      ref = new Date()
      result = new Date +ref + NumberHelper.year(3)

      expect(NumberHelper.since(NumberHelper.year(3), ref)).to.eql result


  describe '::until(num [, reference])', ->

    it 'should return a date that milisecounds of number before reference', ->
      ref = new Date()
      result = new Date +ref - NumberHelper.year(3)

      expect(NumberHelper.until(NumberHelper.year(3), ref)).to.eql result


  describe '::fromNow(num)', ->

    it 'should return a date that milisecounds of number after now', ->
      # untestable


  describe '::ago(num)', ->

    it 'should return a date that milisecounds of number before now', ->
      # untestable


