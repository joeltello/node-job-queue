class ExternalError extends Error
  constructor: (externalMessage, code, err) ->
    console.log ">>>externalMessage", externalMessage
    console.log ">>>err", err
    throw new Error("Cannot instantiate abstract class.") if @constructor is ExternalError
    @message = err?.message or err or "Internal server error"
    Error.captureStackTrace(@, arguments.callee)
    @externalMessage = externalMessage if externalMessage
    @statusCode = code or 500

class InternalServerError extends ExternalError
  constructor: (err) ->
    super("Internal Server Error", 500, err)

class NotFoundError extends ExternalError
  constructor: (err) ->
    err = "Object not found." unless err
    super("Not found", 404, err)

class AccessDeniedError extends ExternalError
  constructor: (err) ->
    super("Access denied", 401, err)

class InvalidParameterError extends ExternalError
  constructor: (externalMessage, err) ->
    externalMessage = "Invalid parameter" unless externalMessage
    err = "Invalid parameter" unless err
    super(externalMessage, 400, err)

# Generic 400, not necessarily related to parameters
class BadRequestError extends ExternalError
  constructor: (externalMessage, err) ->
    externalMessage = "Bad Request" unless externalMessage
    err = "Bad Request" unless err
    super(externalMessage, 400, err)

module.exports =
  ExternalError: ExternalError
  InternalServerError: InternalServerError
  NotFoundError: NotFoundError
  AccessDeniedError: AccessDeniedError
  InvalidParameterError: InvalidParameterError
  BadRequestError: BadRequestError