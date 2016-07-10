fs = require('fs')
_ = require("lodash")
path = require('path')
mongoose = require('mongoose')

lastReconnectAttempt = null

initSchema = (dbUrl, next) ->
  db = mongoose.connection
  options =
    db: native_parser: yes
    server: auto_reconnect: yes
  mongoose.connect dbUrl, options, (err) ->
    next(null, mongoose) unless err
  db.on "error", (err) ->
    console.error "MongoDB connection error", err.message
    mongoose.disconnect()
  # FIXME this is too hacky
  db.on "disconnected", ->
    console.debug "MongoDB disconnected"
    now = (new Date()).getTime()
    # check if the last reconnection attempt was too early
    if lastReconnectAttempt and (now - lastReconnectAttempt) < 5000
      # if it does, delay the next attempt
      delay = 5000 - (now - lastReconnectAttempt)
      console.log "reconnecting to MongoDB in #{delay} ms"
      setTimeout ->
        unless db.readyState
          console.log "reconnecting to MongoDB"
          lastReconnectAttempt = (new Date()).getTime()
          mongoose.connect(dbUrl, server: auto_reconnect: yes)
      , delay
    else
      console.log "reconnecting to MongoDB"
      lastReconnectAttempt = now
      mongoose.connect dbUrl, server: auto_reconnect: yes
  db.on "connected", ->
    console.log "Connection established to MongoDB"
    # init mongoose schemas
    modelFiles = fs.readdirSync(path.join(__dirname, "../models"))
    for modelFile in modelFiles
      if not _.endsWith(modelFile, ".map")
        continue if _.startsWith(modelFile, ".") or fs.statSync(path.join(__dirname, "../models", modelFile)).isDirectory()
        try
          require(path.join(__dirname, "../models", modelFile))
        catch err
          console.error "Error loading model #{modelFile}"
          throw err

module.exports =
  initialize: initSchema