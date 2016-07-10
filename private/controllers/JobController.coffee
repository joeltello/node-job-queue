mongoose = require("mongoose")
EntityController = require("./EntityController")

class JobController extends EntityController

  constructor: ->
    super(mongoose.model("Job"))

#  create: (data) ->
#    console.log "data", data

#  get: (id) ->
#    console.log "id", id
#
#    super().then (result) ->
#      console.log "result", result
#      return result

module.exports = JobController