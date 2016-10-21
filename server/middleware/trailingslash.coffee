REGEX_SLASH_ENDING = /\/$/

module.exports = ->
  (req, res, next) ->
    if req.path.length > 1 and REGEX_SLASH_ENDING.test(req.path)
      res.redirect(301, req.path.slice(0, -1) + req.url.slice(req.path.length))
    else
      next()
