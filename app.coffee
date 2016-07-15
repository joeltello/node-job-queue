express = require("express")
logger = require('morgan')
bodyParser = require('body-parser')
http = require('http')
timeout = require('connect-timeout')
errors = require("./private/lib/errors")
utils = require("./private/lib/utils")
JobService = require("./private/services/JobService")
options = require('./private/middleware/options')
jobs = require('./private/routes/jobs')
config = require("./private/lib/config").get()
startup = require("./private/startup")

app = express()

startup.setupDB config.MONGO_URL, (err) ->

  process.exit(1) if err

  app.set('view engine', 'html')
  app.disable 'x-powered-by'
  app.use options
  app.use timeout(120000)
  app.use logger('dev')
  app.use bodyParser.json(limit: '50mb')
  app.use bodyParser.urlencoded(extended: no, limit: '50mb')

  app.use('/api/1.0/jobs', jobs)

  # initialize services
  JobService.start()

  # catch 404 and forward to error handler
  app.use (req, res, next) ->
    next(new errors.NotFoundError())

  # development error handler
  # will print stacktrace
  if app.get('env') is 'development'
    app.use (err, req, res, next) ->
      res.status(err.status || 500)
      res.json
        status: "error"
        message: err.message
        error: err

  # production error handler
  # no stacktraces leaked to user
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    res.json
      status: "error"
      message: err.message
      error: {}

  # Globar error handler
  process.on 'uncaughtException', (err) ->
    console.error "Uncaught exception:", err
    process.exit(1) if err.message is "listen EADDRINUSE"

module.exports = app