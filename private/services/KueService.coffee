kue = require('kue')
_ = require('lodash')
config = require("../lib/config").get()

# singleton, only one queue
class KueService

  # private properties
  queue = null

  # private class
  class Queue

    queue = null
    exiting = no
    reattempts = 5

    constructor: ->
      # TODO pass redis config as parameters
      redisConfig = config.REDIS unless _.isEmpty(config.REDIS)
      # it will default to 127.0.0.1:6379 if redisConfig is empty
      queue = kue.createQueue(redis: redisConfig)
      startQueue()
      return queue

    safelyExit = ->
      return if exiting
      exiting = yes
      queue.shutdown 2000, (err) ->
        console.log 'KueService::safelyExit() - shutdown', err or 'OK'
        process.exit(0)

    reattemptJobs = (err, ids) ->
      return console.error "KueService::reattemptJobs() - Error loading failed jobs", err if err
      ids.forEach (id) ->
        kue.Job.get id, (err, job) ->
          return console.error "KueService::reattemptJobs() - Error loading job #{id}", err if err
          console.log "KueService::reattemptJobs() - Reattempting job:", id, "Status:", job.state()
          try
            job.reattempt reattempts, (err) ->
              return console.error "KueService::reattemptJobs() - Error restarting job:", id, "Status:", job.state(), err if err
              console.log "KueService::reattemptJobs() - Job restarted:", id, "Status:", job.state()

    startQueue = ->
      process.once 'SIGINT', safelyExit
      process.once "SIGTERM", safelyExit
      queue.watchStuckJobs(5000)
      # FIXME this could cause a memory leak
      # Monitoring jobs
      setInterval ->
        queue.inactiveCount (err, total) ->
          console.log "KueService - Inactive count:", total
          queue.inactive(reattemptJobs) if total > 0
        queue.activeCount (err, total) ->
          console.log "KueService - Active count:", total
        queue.completeCount (err, total) ->
          console.log "KueService - Complete count:", total
        queue.delayedCount (err, total) ->
          console.log "KueService - Delayed count:", total
        queue.failedCount (err, total) ->
          console.log "KueService - Failed count:", total
          queue.failed(reattemptJobs) if total > 0
      , 60000 # every minute

  # Static method - Get the singleton instance
  @getQueue: ->
    queue ?= new Queue()
    return queue

module.exports = KueService