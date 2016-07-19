expect = require('chai').expect
KueService = require("../../private/services/KueService")

describe "KueService", ->

  describe "getQueue()", ->
    
    it "should return the same queue (singleton)", ->
      queue1 = KueService.getQueue()
      queue2 = KueService.getQueue()
      expect(queue1).to.equal(queue2)