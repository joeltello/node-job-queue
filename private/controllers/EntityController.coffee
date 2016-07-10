q = require("when")
async = require("asyncawait/async")
await = require("asyncawait/await")
guard = require("../lib/guard")
errors = require("../lib/errors")
utils = require("../lib/utils")

class EntityController

  # Hack to get around CoffeeScript issue with 'super' https://github.com/jashkenas/coffeescript/issues/1606
  super: (methodName, args...)->
    @constructor.__super__[methodName].apply(@, args)

  constructor: (model) ->
    throw new errors.InvalidParameterError("Type not permitted.") if @constructor is EntityController
    guard.required("Model", model)
    @model = model

  onBeforeCreate: async (data) ->
    entity = new @model(data)
    await entity.validate()
    return entity

  # TODO
  onAfterCreate: async (result) ->
    return result

  create: async (data)->
    entity = await @onBeforeCreate(data)
    result = await entity.save()
    return await @onAfterCreate(result)

  # TODO
  onBeforeSearch: (query) ->
    return @model.find().where("deleted_at").exists(no)

  # TODO
  onAfterSearch: (results, query) ->
    return q.resolve(results)

  # TODO support query
  search: async (query) ->
    filteredQuery = @onBeforeSearch(query) # query
    results = await filteredQuery.lean(no).exec()
    return await @onAfterSearch(results, query)

  onBeforeGet: (id) ->
    return @model.findOne(_id: id, deleted_at: $exists: no)

  onAfterGet: async (result) ->
    return q.resolve(result)

  get: async (id) ->
    filteredQuery = @onBeforeGet(id)
    instance = await filteredQuery.lean(no).exec()
    throw new errors.NotFoundError() unless instance
    return await @onAfterGet(instance)

  onBeforeUpdate: async (currentInstance, data) ->
    _.extend currentInstance, data
    await currentInstance.validate()
    return currentInstance

  onAfterUpdate: async (result) ->
    return q.resolve(result)

  update: async (id, data) ->
    currentEntity = await utils.findById(id)
    throw new errors.NotFoundError() unless currentEntity
    entityToSave = await @onBeforeUpdate(currentEntity, data)
    updatedEntity = await entityToSave.save()
    return await @onAfterUpdate(updatedEntity)

  onBeforeDelete: async (currentInstance) ->
    return q.resolve(currentInstance)

  onAfterDelete: async (result) ->
    return q.resolve(result)

  delete: async (id) ->
    result = await @model.findOne(_id: id, deleted_at: $exists: no)
    throw new errors.NotFoundError() unless result
    instanceToDelete = await @onBeforeDelete(result)
    instanceToDelete.deleted_at = Date.now()
    await instanceToDelete.save()
    return await @onAfterDelete(instanceToDelete)

module.exports = EntityController