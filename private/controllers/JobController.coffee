mongoose = require("mongoose")
postal = require("postal")
_ = require("lodash")
async = require("asyncawait/async")
await = require("asyncawait/await")
utils = require("../lib/utils")
JobService = require("../services/JobService")
EntityController = require("./EntityController")

class JobController extends EntityController

  constructor: ->
    super(mongoose.model("Job"))

  onAfterCreate: (job) ->
    super(job).then async (job) ->
      job = await JobService.queue(job)
      return job

  onAfterGet: (result) ->
    super(result).then (job) ->
      if job.status is "complete" and job.result
        return job.result
      else
        return job

  # static
  # FIXME find a way to call @update (super) from EntityController (scope/this issue)
  update = async (data) ->
    job = await utils.findById(data._id)
    throw new errors.NotFoundError() unless job
    job = _.extend job, data.data
    await job.validate()
    return await job.save()

  postal.subscribe channel: "Global", topic: "Job.update", callback: update

module.exports = JobController