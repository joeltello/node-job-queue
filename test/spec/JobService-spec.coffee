expect = require('chai').expect

describe "JobService", ->

  describe "start()", ->
    
    it "should return -1 when not present", ->
      expect([1,2,3].indexOf(4)).to.equal(-1)