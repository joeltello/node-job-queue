fs = require('fs')
Q = require("when")
_ = require("lodash")
path = require('path')
mongoose = require("mongoose")
utils = require("./utils")
guard = require("./guard")
errors = require("./errors")
await = require('asyncawait/await')
async = require('asyncawait/async')

class AbstractDao

  constructor: (context, model) ->
    throw new errors.InvalidParameterError("Type not permitted.") if @constructor is DaoService
    guard.required("Model", model)
    @type = model.modelName
    @model = model

  onBeforeCreate: async (data) ->
    entity = new @model(data)
    await entity.validate()
    return entity

  onAfterCreate: (result) ->
    return Q.resolve(result)

  create: async (data) ->
    entity = await @onBeforeCreate(data)
    try
      result = await entity.save()
      return await @onAfterCreate(result)
    catch err
      console.error "DaoService::#{@type}::create() - Unable to save '#{entity._id}'. Details:", err
      throw new errors.InternalServerError("Unable to save #{entity._id}.")

  onBeforeGet: (id) ->
    return @model.findById(id).where("deleted_at").exists(no).lean(no)

  onAfterGet: (result) ->
    return Q.resolve(result)

  get: async (id) ->
    query = @onBeforeGet(id)
    result = await query.exec()
    throw new errors.NotFoundError() unless result
    return await @onAfterGet(result)

  # TODO
  # onBeforeSearch: ->
  # onAfterSearch: ->
  # search: ->

  onBeforeUpdate: async (currentInstance, data) ->
    _.extend currentInstance, data
    await currentInstance.validate()
    return currentInstance

  onAfterUpdate: (result) ->
    return Q.resolve(result)

  update: async (id, data) ->
    currentEntity = await utils.findById(id)
    throw new errors.NotFoundError() unless currentEntity
    entityToSave = await @onBeforeUpdate(currentEntity, data)
    updatedEntity = await entityToSave.save()
    return await @onAfterUpdate(updatedEntity)

  onBeforeDelete: (currentInstance) ->
    return Q.resolve(currentInstance)

  onAfterDelete: (result) ->
    return Q.resolve(result)

  delete: async (id) ->
    instance = await utils.findById(id)
    throw new errors.NotFoundError() unless instance
    instanceToDelete = await @onBeforeDelete(instance)
    instanceToDelete.deleted_at = Date.now()
    savedResult = await instanceToDelete.save()
    return await @onAfterDelete(savedResult)

  setModel: (modelName) ->
    guard.required("modelName", modelName, _.isString)
    model = mongoose.model(modelName)
    throw new errors.InvalidParameterError("Invalid model specified. " + modelName) unless model
    @model = model
    @resourceFilter = new ResourceFilter(@context, model)

module.exports = AbstractDao