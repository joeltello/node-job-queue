env = require('../../config.json');

module.exports =
  
  get: ->
    node_env = process.env.NODE_ENV or 'development'
    return env[node_env]