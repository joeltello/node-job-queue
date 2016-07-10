express = require("express")
#startup = require("./startup")
cluster = require('cluster')
compression = require('compression')
bodyParser = require('body-parser')
os = require('os')
options = require('./middleware/options')
routesApi = require('./routes/routes.api.v1')

process.on 'uncaughtException', (err) ->
  console.error "Uncaught exception:", err
  process.exit(1) if err.message is "listen EADDRINUSE"
  cluster.worker?.kill()

module.exports = (config) ->
  if cluster.isMaster
    process.title = 'Job Queue (master)'
    if config.CLUSTER_ENABLED
      workerCount = config.CLUSTER_WORKERS or os.cpus().length
      console.log "Starting #{workerCount} workers"
      for i in [1..workerCount]
        console.log "Starting worker:", i
        cluster.fork()
      # only master cluster can fork new workers
      cluster.on 'exit', (worker, code, signal) ->
        console.error "#{worker.id} - worker exited:", signal, code or "" if signal isnt "SIGTERM"
        cluster.fork()
      return
  else
    process.title = "Job Queue (worker #{cluster.worker?.id})"
  app = express()
  app.port = config.PORT
  app.disable('x-powered-by')
  app.use compression()
  app.use options
  app.use require('method-override')()
  app.use require('connect-timeout')(120000)
  app.use bodyParser.urlencoded(extended: no, limit: '50mb')
  app.use bodyParser.json(limit: '50mb')
  routesApi(app)
  app.listen app.port, ->
    console.log("Job Queue worker #{cluster.worker?.id or "MASTER"} listening...")