_ = require("lodash")
mongoose = require("mongoose")
errors = require("./errors")
uuid = require('uuid')

getModelFromEntityId = (id) ->
  dashPos = id?.indexOf("-")
  throw new errors.InvalidParameterError("Provided id is invalid") unless dashPos > 0
  modelName = id.substr(0, dashPos)
  modelName = _.find mongoose.modelNames(), (name) ->
    return name if modelName.toLowerCase() is name.toLowerCase()
  throw new errors.InvalidParameterError("Provided id is invalid") unless modelName
  return mongoose.model(modelName)

# Filters out deleted objects
findById = (id, lean = no) ->
  return getModelFromEntityId(id).findOne(_id: id).where("deleted_at").exists(no).lean(lean)

generateId = ->
  uuid.v4()

module.exports =
  findById: findById
  generateId: generateId