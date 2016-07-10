schema = require('./lib/dbschema')

module.exports =

  setupDB: (dbUrl, next) ->
    try
      schema.initialize(dbUrl, next)
    catch e
      console.error "setupDB() - DB connection error", e
      return process.exit(1)