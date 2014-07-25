{ chai, expect } = require '../test_helpers'
DateHelper       = require '../../src/supports/date_helper'


describe 'DateHelper', ->

  describe '::now()', ->

    it 'should return current datetime', ->
      # untestable


  describe '::today()', ->

    it 'should return today\'s date', ->
      today = new Date()
      today.setHours 0
      today.setMinutes 0
      today.setSeconds 0
      today.setMilliseconds 0

      expect(DateHelper.today()).to.eql today


  describe '::equals(one, other)', ->

    it 'should return true if the objects are the same "date"', ->
      d1 = new Date 2000, 2, 2, 1, 1, 1
      d2 = new Date 2000, 2, 2, 3, 4, 5

      expect(DateHelper.equals(d1, d2)).to.equal true
      expect(DateHelper.equals(d2, d1)).to.equal true

    it 'should return false if the object are different date', ->
      d1 = new Date 2000, 2, 2, 1, 1, 1
      d2 = new Date 2000, 2, 9, 3, 4, 5

      expect(DateHelper.equals(d1, d2)).to.equal false
      expect(DateHelper.equals(d2, d1)).to.equal false


  describe '::isLeapYear(date)', ->

    it 'should return true if it is leap year', ->
      d = new Date 2004, 0
      expect(DateHelper.isLeapYear(d)).to.be.true


  describe '::getMonthName(date)', ->

    it 'should return name of month', ->
      d = new Date 1993, 8, 21
      expect(DateHelper.getMonthName(d)).to.equal 'September'


  describe '::getDaysInMonth(date)', ->

    it 'should return 31 for January, March, May, July, August, October and December', ->
      d = new Date 2000, 0
      expect(DateHelper.getDaysInMonth(d)).to.equal 31

    it 'should return 30 for April, June, September and November', ->
      d = new Date 2000, 3
      expect(DateHelper.getDaysInMonth(d)).to.equal 30

    it 'should return 29 for February of leap year', ->
      d = new Date 2004, 1
      expect(DateHelper.getDaysInMonth(d)).to.equal 29

    it 'should return 28 for February of normal year', ->
      d = new Date 2005, 1
      expect(DateHelper.getDaysInMonth(d)).to.equal 28


  describe '::isToday(date)', ->

    it 'should return true for today\'s date', ->
      now = new Date()
      d = new Date now.getFullYear(), now.getMonth(), now.getDate(), 10, 10, 10

      expect(DateHelper.isToday(d)).to.be.true


  describe '::toFormattedString(date, format)', ->

  describe '::relativeDate(date)', ->

  describe '::relativeTime(date, options = {})', ->

  describe '::since(date, reference)', ->

  describe '::ago(date, reference)', ->

  describe '::beginningOfDay(date)', ->

    it 'should reset hours, minutes and seconds of date', ->
      d = new Date 2000, 2, 2, 10, 10, 10
      bd = DateHelper.beginningOfDay d

      expect(bd.getFullYear()).to.equal 2000
      expect(bd.getMonth()).to.equal 2
      expect(bd.getDate()).to.equal 2
      expect(bd.getHours()).to.equal 0
      expect(bd.getMinutes()).to.equal 0
      expect(bd.getSeconds()).to.equal 0


  describe '::beginningOfWeek(date)', ->

  describe '::beginningOfMonth(date)', ->

  describe '::beginningOfQuarter(date)', ->

  describe '::beginningOfYear(date)', ->

  describe '::endOfDay(date)', ->

  describe '::endOfMonth(date)', ->

  describe '::endOfQuarter(date)', ->

  describe '::yesterday(date)', ->

    it 'should return date of yesterday', ->
      today = new Date()
      yesterday = new Date(+today - 24 * 60 * 60 * 1000)

      expect(DateHelper.yesterday(today)).to.eql yesterday


  describe '::tomorrow(date)', ->

    it 'should return date of tomorrow', ->
      today = new Date()
      tomorrow = new Date(+today + 24 * 60 * 60 * 1000)

      expect(DateHelper.tomorrow(today)).to.eql tomorrow


  describe '[alias] ::strftime -> ::toFormattedString', ->

  describe '[alias] ::midnight -> ::beginningOfDay', ->

  describe '[alias] ::monday -> ::beginningOfWeek', ->

  describe '[alias] ::until -> ::ago', ->

