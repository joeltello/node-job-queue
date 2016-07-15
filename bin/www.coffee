#!/usr/bin/env node

###
Module dependencies.
###
config = require('../private/lib/config').get()
app = require('../app')
debug = require('debug')('minimal-job-queue:server')
http = require('http')

###
Normalize a port into a number, string, or false.
###

normalizePort = (val) ->
  port = parseInt(val, 10)
  if isNaN(port)
# named pipe
    return val
  if port >= 0
# port number
    return port
  return no

###
Event listener for HTTP server "error" event.
###

onError = (error) ->
  throw error if error.syscall isnt 'listen'
  bind = if typeof port is 'string' then 'Pipe ' + port else 'Port ' + port
  # handle specific listen errors with friendly messages
  switch error.code
    when 'EACCES'
      console.error(bind + ' requires elevated privileges')
      process.exit(1)
      break
    when 'EADDRINUSE'
      console.error(bind + ' is already in use')
      process.exit(1)
      break
    else
      throw error

###
Event listener for HTTP server "listening" event.
###
onListening = ->
  addr = server.address()
  bind = if typeof addr is 'string' then 'pipe ' + addr else 'port ' + addr.port
  debug('Listening on ' + bind)

###
Get port from environment and store in Express.
###
port = normalizePort(config.PORT or 3000)
app.set 'port', port

###
Create HTTP server.
###
server = http.createServer(app)

###
Listen on provided port, on all network interfaces.
###

server.listen(port)
server.on('error', onError)
server.on('listening', onListening)