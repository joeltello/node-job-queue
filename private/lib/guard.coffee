_ = require("lodash")
errors = require("./errors")

module.exports =

  required: (name, val, func = (x) -> !!x) ->
    throw new errors.InvalidParameterError("#{name} is required.") unless func(val)

  requiredArray: (name, val) ->
    throw new errors.InvalidParameterError("#{name} is required to be an array.") unless _.isArray(val)