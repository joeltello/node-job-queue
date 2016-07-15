express = require("express")
router = express.Router()

RequestHandler = require("../lib/requesthandler")

router.post "/", (req, res) ->
  new RequestHandler(req, res, "job").create(req.body)

router.get "/:id", (req, res) ->
  new RequestHandler(req, res, "job").get(req.params["id"])

module.exports = router