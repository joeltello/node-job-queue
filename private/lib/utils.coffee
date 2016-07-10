#request = require('request')
#fs = require("fs")
_ = require("lodash")
Q = require("when")
#uuid = require("uuid")
#moment = require("moment")
mongoose = require("mongoose")
errors = require("./errors")
#shortid = require('shortid')

# HEADSUP! FILES are cached
cachedFiles = {}

readFile = (path, encoding, callback) ->
  if not cachedFiles[path]?
    fs.readFile path, encoding: encoding, (err, file) ->
      return callback(err) if err
      cachedFiles[path] = file
      callback(null, cachedFiles[path])
  else
    callback(null, cachedFiles[path])

getUniqueId = (model, objectName)->
  throw new Error("Model is required") unless model
  deferred = Q.defer()
  index = 1
  objectName = objectName?.replace(/[^A-Z0-9a-z@\.\-_]/g, '').toLowerCase()
  unless objectName
    objectName = uuid.v4().replace(/\-/g, '')
  id = model.modelName.toLowerCase() + "-" + objectName
  currentId = id
  idSearcher = ->
    model.findOne _id: currentId, (err, result)->
      return deferred.reject(new Error("Error looking up unique object id", err)) if err
      if not result
        logger.debug "UNIQUE ID GENERATED", currentId
        return deferred.resolve(currentId)
      currentId = id + index
      index++
      setTimeout(idSearcher, 0)
  idSearcher()
  return deferred.promise

getModelNameFromEntityId = (id)->
  dashPos = id.indexOf("-")
  throw new errors.InvalidParameterError("Provided id is invalid") unless dashPos > 0
  modelName = id.substr(0, dashPos)
  modelName = _.find mongoose.modelNames(), (name)->
    if modelName.toLowerCase() is name.toLowerCase()
      name
  modelName

normalizeModelName = (nameToNormalize)->
  nameToNormalize = _.find mongoose.modelNames(), (name)->
    if nameToNormalize.toLowerCase() is name.toLowerCase()
      name
  nameToNormalize



resolveEntities = (ids, lean = true)->
  if not _.isArray(ids)
    ids = [ids]
  if not _.every(ids, (id)->_.isString(id))
    throw new errors.InvalidParameterError("Some of IDs are not strings.")
  idGroups = _.groupBy(ids, (id)->id.split("-")[0])
  promises = []
  for entityName, entityIds of idGroups
    modelName = normalizeModelName(entityName)
    unless modelName
      throw new Error("Invalid entity ID: " + entityName)
    query = mongoose.model(modelName).find({_id: {$in: entityIds}}).where(deleted_at: {$exists: false}).lean(lean)
    promises.push(query.exec())
  Q.all(promises).then (entities)->
    _.flatten(entities)

convertToMongooseInstance = (objects)->
  convert = (o)->
    Model = getModelFromEntityId(o._id)
    return new Model(o)
  if not _.isArray(objects)
    return convert(objects)
  return _.map objects, convert

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
  return getModelFromEntityId(id).findById(id).where("deleted_at").exists(no).lean(lean)

deleteRelated = (modelName, associatedObjectId, deletedById, purge = no)->
  model = mongoose.model(modelName)
  unless model
    throw new Error("A valid model name is required. Model not found: " + modelName)
  logger.debug "Deleting related #{modelName}s to #{associatedObjectId}"
  promise = null
  if purge
    promise = model.remove(associations: associatedObjectId)
  else
    promise = model.update(associations: associatedObjectId, {deleted_at: Date.now(), deleted_by: deletedById}, {multi: yes})
  promise.then (result) ->
    logger.debug "Deleted related #{modelName}:", JSON.stringify(result)
    return result.nModified or result.nRemoved
  , (err)->
    logger.error "Error deleting related #{modelName}", err


cloneDeep = (obj)->
  return obj unless obj?
  JSON.parse(JSON.stringify(obj))

generateId = ->
  shortid.generate()

ensureReferencesInAssociations = (associations, ids) ->
  ids = [ids] if not _.isArray(ids)
  for ref in ids
    associations.push ref if ref not in associations
  return associations

filterIdByModelName = (ids, modelName)->
  _.filter ids, (id)->
    id.indexOf(modelName.toLowerCase() + "-") is 0

# Extracts values for a specified key inside nested object
extractProperty = (obj, key) ->
  return [] unless obj
  values = []
  for k, v of obj
    if k is key
      values.push(v)
    if _.isObject(v)
      values.push extractProperty(v, key)
  return _.flatten(values)

module.exports =
  findById: findById
#  convertToMongooseInstance: convertToMongooseInstance
#  getUniqueId: getUniqueId
#  resolveEntities: resolveEntities
#  generateId: generateId
#  model:
#    getNameFromEntityId: getModelNameFromEntityId
#    getFromEntityId: getModelFromEntityId
#    normalizeName: normalizeModelName
#  id:
#    filterByModelName: filterIdByModelName