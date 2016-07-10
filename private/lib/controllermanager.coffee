_ = require("lodash")
fs = require('fs')
path = require("path")
q = require("when")
EntityController = require("../controllers/EntityController")
guard = require("./guard")
utils = require("./utils")
errors = require("./errors")

class ControllerManager

  controllers = {}

  initControllers = ->
    return unless _.isEmpty(controllers)
    controllersRoot = path.join(__dirname, "../controllers")
    controllerNames = _.uniq _.map fs.readdirSync(controllersRoot), (f) -> f.split('.')[0]
    for controllerName in controllerNames
      if controllerName isnt "EntityController"
        try
          controllers[controllerName.toLowerCase()] = require(path.join(controllersRoot, controllerName))
        catch err
          console.error "ControllerManager::createController(#{controllerName}) - error:", err

  # Static method to load a manager
  createController = (controllerName) ->
    initControllers()
    guard.required("ControllerName", controllerName)
    controllerName = controllerName.toLowerCase()
    if /s$/.test controllerName # is it plural?
      # This is a simplistic anti-pluralize method to be able to refer to /user and /users
      # and other similar objects interchangeably
      controllerName = controllerName.replace(/s$/, "")
    controllerName = controllerName + "controller"
    ControllerType = controllers[controllerName]
    if not ControllerType
      console.error "ControllerManager::createController(#{controllerName}) - controller not found,"
      throw new errors.InvalidParameterError("Specified action is not supported.")
    return new ControllerType()

  constructor: (req, res, type) ->
    throw new Error("Missing required parameters.") unless req and res and type
    throw new Error("Model type is required to be a string.") if typeof type isnt "string"
    @req = req
    @res = res
    @type = type

  failRequest: (err) ->
    try
      if err.name is "ValidationError"
        @res.status(400)
        return @res.json err
      err = new errors.InternalServerError(err) unless err instanceof errors.ExternalError
      console.error @req.path, err.externalMessage, "->", err.message, err.statusCode
      @res.status err.statusCode or 500
      @res.json message: err.externalMessage
    catch err
      return if err.message is "Can't set headers after they are sent." # timeout
      console.error "Unexpected error", err
      try
        @res.status 500
        @res.json message: "Internal Server Error"
      finally
      try @res.end()

  processRequest: (executor) ->
    controller = null
    try
      controller = createController(@type)
    catch err
      console.error "Error creating #{@type} controller:", err.externalMessage or err.message
      return @failRequest(err)
    try
      q(executor(controller))
      .then (data) =>
        if data?.status_code
          @res.status(data.status_code)
          delete data.status_code
        if data?.redirect?.url
          @res.redirect(data.redirect.url)
        else if data instanceof Buffer
          @res.send(data)
        else
          @res.json(data)
      .catch (err) =>
        @failRequest(err)
    catch err
      @failRequest(err)

  action: (actionName, options...) ->
    @processRequest (manager) ->
      throw new errors.NotFoundError() if typeof manager[actionName] isnt "function"
      return manager[actionName].apply(manager, options)

  get: (id, query) ->
    @action("get", id, query)

  update: (id, data)->
    @action("update", id, data)

  create: (data)->
    @action("create", data)

  delete: (id)->
    @action("delete", id)

  search: (query)->
    @action("search", query)

module.exports = ControllerManager
