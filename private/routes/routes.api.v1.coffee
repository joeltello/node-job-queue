ControllerManager = require("../lib/controllermanager")

module.exports = (server) ->

  server.post "/api/1.0/job", (req, res) ->
    new ControllerManager(req, res, "job").create(req.body)
    
  server.get "/api/1.0/job/:id", (req, res) ->
    new ControllerManager(req, res, "job").get(req.params["id"])