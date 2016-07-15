class ExternalError extends Error
  constructor: (details, err, code) ->
    throw new Error("Cannot instantiate abstract class.") if @constructor is ExternalError
    @message = err?.message or err or "Internal server error"
    Error.captureStackTrace(@, arguments.callee)
    @details = details if details
    @status = code or 500
    @statusCode = code or 500

class InternalServerError extends ExternalError
  constructor: (details, err) ->
    details = "Invalid Parameter" unless details
    err = "Invalid Parameter" unless err
    super(details, err, 500)

class NotFoundError extends ExternalError
  constructor: (details, err) ->
    details = "Not Found" unless details
    err = "Not Found" unless err
    super(details, err, 404)

class AccessDeniedError extends ExternalError
  constructor: (details, err) ->
    details = "Access Denied" unless details
    err = "Access Denied" unless err
    super(details, err, 401)

class InvalidParameterError extends ExternalError
  constructor: (details, err) ->
    details = "Invalid Parameter" unless details
    err = "Invalid Parameter" unless err
    super(details, err, 400)

# Generic 400, not necessarily related to parameters
class BadRequestError extends ExternalError
  constructor: (details, err) ->
    details = "Bad Request" unless details
    err = "Bad Request" unless err
    super(details, err, 400)

module.exports =
  ExternalError: ExternalError
  InternalServerError: InternalServerError
  NotFoundError: NotFoundError
  AccessDeniedError: AccessDeniedError
  InvalidParameterError: InvalidParameterError
  BadRequestError: BadRequestError