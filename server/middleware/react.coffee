winston = require('winston')
config = require('config')

React = require('react')
{ renderToString } = require('react-dom/server')
{ match, RouterContext } = require('react-router')

routes = require('../../client/routes')
Error404 = require('../../client/containers/error')

isError = (props) -> Error404 in props.components


module.exports = ->
  (req, res, next) ->
    match({ routes, location: req.originalUrl }, (error, redirect, props) ->
      if error
        winston.error("Request #{req.originalUrl} failed: #{error.message}")
        return next()

      if redirect
        return res.redirect(302, redirect.pathname + redirect.search)

      if not props
        return next()

      status = if isError(props) then 404 else 200
      res.status(status)
      res.render('index', content: renderToString(<RouterContext {...props} />))
    )

