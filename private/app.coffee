express = require("express")
startup = require("./startup")
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
  startup.setupDB config.MONGO_URL, (err) ->
    process.exit(1) if err
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
    server = express()
    server.port = config.PORT
    server.disable('x-powered-by')
    server.use compression()
    server.use options
    server.use require('method-override')()
    server.use require('connect-timeout')(120000)
    server.use bodyParser.urlencoded(extended: no, limit: '50mb')
    server.use bodyParser.json(limit: '50mb')
    routesApi(server)
    server.listen server.port, ->
      console.log("Job Queue worker #{cluster.worker?.id or "MASTER"} listening...")