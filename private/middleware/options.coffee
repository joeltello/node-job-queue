module.exports = (req, res, next) ->
  if req.method is "OPTIONS"
    res.status(200)
    res.end()
  else
    next()