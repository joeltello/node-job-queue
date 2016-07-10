EntityController = require("../controllers/EntityController")
utils = require("./utils")
errors = require("./errors")

class RequestProcessor

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
      controller = EntityController.create(@type)
    catch err
      console.error "Error creating #{@type} controller:", err.externalMessage or err.message
      return @failRequest(err)
    try
      Q(executor(controller))
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

module.exports = RequestProcessor
