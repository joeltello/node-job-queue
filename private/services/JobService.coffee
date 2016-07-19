q = require("when")
await = require("asyncawait/await")
async = require("asyncawait/async")
request = require("request")
postal = require("postal")
KueService = require("./KueService")
config = require("../lib/config").get()

# TODO dependency injection
class JobService
  
  # private variables
  parallelJobs = config.PARALLEL_JOBS
  attempts = 5
  initialized = no
  
  # private methods
  jobProcessor = (job, done) ->
    job = job.data
    # TODO change to streams (issue with large files)
    request job.url, async (err, response, body) ->
      if err
        done(err)
      else
        done(null, body)
  
  # static
  @start: ->
    return if initialized
    queue = KueService.getQueue()
    queue.process "jobs", parallelJobs, jobProcessor
    initialized = yes
  
  # static 
  @queue: (job) ->
    deferred = q.defer()
    queue = KueService.getQueue()
    queue.create("jobs", job)
    .removeOnComplete(yes)
    .attempts(attempts)
    .backoff(yes)
    .on "enqueue", async ->
      console.log "JobService::queue() - job is now queued", job._id
      postal.publish(channel: "Global", topic: "Job.update", data: {_id: job._id, data: {status: "queued"}})
    .on "start", async ->
      console.log "JobService::queue() - the job is now running", job._id
      postal.publish(channel: "Global", topic: "Job.update", data: {_id: job._id, data: {status: "running"}})
    .on "promotion", ->
      console.log "JobService::queue() - the job is promoted from delayed state to queued", job._id
    .on "failed attempt", async (result) ->
      console.log "JobService::queue() - the job's attempt failed", job._id, result
      postal.publish(channel: "Global", topic: "Job.update", data: {_id: job._id, data: {status: "retrying"}})
    # the job has failed and has no remaining attempts
    .on "failed", async (err) ->
      console.error "JobService::queue() - job failed", job._id, err
      postal.publish(channel: "Global", topic: "Job.update", data: {_id: job._id, data: {status: "failed"}})
    .on "complete", async (res) ->
      console.log "JobService::queue() - job has been completed", job._id
      postal.publish(channel: "Global", topic: "Job.update", data: {_id: job._id, data: {status: "complete", result: res}})
    # the job has been removed
    .on "remove", (result) ->
      console.log "JobService::queue() - job has been removed", job._id, result
    .save async (err) ->
      if err
        console.log "JobService::queue() - Couldn't add job to queue", job._id, err
        job.status = "failed"
      else
        console.log "JobService::queue() - Job added to queue", job._id
        job.status = "added"
      postal.publish(channel: "Global", topic: "Job.update", data: {_id: job._id, data: {status: "added"}})
      deferred.resolve(job)
    return deferred.promise

module.exports = JobService