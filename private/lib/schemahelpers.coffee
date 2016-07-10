utils = require("./utils")

module.exports =
  
  idDefault: (typeName) ->
    return -> "#{typeName}-#{utils.generateId()}"