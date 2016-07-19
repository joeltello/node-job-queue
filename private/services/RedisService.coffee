_ = require("lodash")
q = require("when")
uuid = require("uuid")
redis = require("redis")
await = require('asyncawait/await')
async = require('asyncawait/async')
guard = require("../lib/guard")
config = require("../lib/config").get()

# TODO make it singleton
class RedisService
  
  client = null
  
  constructor: ->
    # TODO pass redis config as parameters
    redisConfig = config.REDIS unless _.isEmpty(config.REDIS)
    # it will default to 127.0.0.1:6379 if redisConfig is empty
    client = redis.createClient(redisConfig)
    if password
      client.auth password, (err) ->
        console.error "RedisService::auth() - error:", err
    client.on "error", (err) ->
      console.error "RedisService::error -", err.message
    client.on "ready", ->
      console.log "RedisService::ready - initialized. Server version:", client.server_info.redis_version

  get: (id) ->
    guard.required("id", id)
    deferred = q.defer()
    client.get id, (err, obj) ->
      if client.connected and err
        console.error "RedisService::get() - error:", err?.message
      try
        deferred.resolve(JSON.parse(obj))
      catch e
        console.error "RedisService::get() - doc #{id} error parsing JSON", obj
        deferred.reject(e)
    return deferred.promise

  save: (obj) ->
    guard.required("object", obj, _.isObject)
    obj.id ?= uuid.v4()
    deferred = q.defer()
    stringifiedObject = JSON.stringify(obj)
    client.set obj.id, stringifiedObject, (err) ->
      if client.connected and err
        console.error "RedisService::set() - error saving document", err?.message
        deferred.reject(err)
      else
        client.persist(obj.id)
        deferred.resolve(obj)
    return deferred.promise
  
  update: async (id, data = {}) ->
    guard.required("id", id)
    obj = await get(id)
    obj = _.extend obj, data
    return await save(obj)

  del: (id) ->
    guard.required("id", id)
    deferred = q.defer()
    client.del id, (err) ->
      if client.connected and err
        console.error "RedisService::set() - error deleting document", err?.message
      deferred.resolve()
    return deferred.promise

module.exports = RedisService