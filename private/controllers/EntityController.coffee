fs = require('fs')
Q = require("when")
_ = require("lodash")
path = require('path')
guard = require("../lib/guard")
errors = require("../lib/errors")
AbstractDao = require("../lib/AbstractDao")

class EntityController extends AbstractDao

  controllers = {}

  constructor: ->
    throw new errors.InvalidParameterError("Type not permitted.") if @constructor is EntityController
    return super

  @initControllers: ->
    return unless _.isEmpty(controllers)
    controllerNames = _.uniq _.map fs.readdirSync(__dirname), (f) -> f.split('.')[0]
    for controllerName in controllerNames
      if controllerName isnt "EntityController"
        try
          controllers[controllerName.toLowerCase()] = require(path.join(__dirname, controllerName))
        catch err
          console.error "Error initializing controller:", controllerName, err

  # Static method to load a manager
  @create: (controllerName) ->
    @initControllers()
    guard.required("ControllerName", controllerName)
    controllerName = controllerName.toLowerCase()
    if /s$/.test controllerName # is it plural?
      # This is a simplistic anti-pluralize method to be able to refer to /job and /jobs
      # and other similar objects interchangeably
      controllerName = controllerName.replace(/s$/, "")
    controllerName = controllerName + "controller"
    ControllerType = controllers[controllerName]
    throw new errors.NotFoundError() unless ControllerType
    return new ControllerType()

  onBeforeCreate: (data) ->
    super(data)

  onAfterCreate: -> super.then (result) =>
    return Q.resolve(result)

  onAfterSearch: -> super.then (result) =>
    return result

  onAfterGet: -> super.then (result) =>
    return Q.resolve(result)

  onBeforeUpdate: (currentInstance, data) ->
    super(currentInstance, data)

  onAfterUpdate: -> super.then (result) =>
    return Q.resolve(result)

  onAfterDelete: -> super.then (result) =>
    return Q.resolve(result)

module.exports = EntityController