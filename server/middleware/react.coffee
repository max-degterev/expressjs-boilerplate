winston = require('winston')

React = require('react')
{ renderToString } = require('react-dom/server')
{ match, RouterContext } = require('react-router')
routes = require('../../client/routes')
config = require('config')


module.exports = ->
  (req, res, next) ->
    match({ routes, location: req.originalUrl }, (error, redirectLocation, renderProps) ->
      if error
        winston.error("Request #{req.originalUrl} failed: #{error.message}")
        return next()

      if redirectLocation
        return res.redirect(302, redirectLocation.pathname + redirectLocation.search)

      if renderProps
        res.render('index', content: renderToString(<RouterContext {...renderProps} />))
      else
        next()
    )

