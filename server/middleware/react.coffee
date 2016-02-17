winston = require('winston')
config = require('config')

{ minify } = require('html-minifier')

React = require('react')
{ Provider } = require('react-redux')
{ renderToString } = require('react-dom/server')
{ match, RouterContext, createMemoryHistory } = require('react-router')

createStore = require('../../client/modules/store')
routes = require('../../client/routes')
Error404 = require('../../client/containers/error')

MINIFY_OPTIONS =
  removeComments: true
  collapseWhitespace: true
  collapseBooleanAttributes: true
  removeAttributeQuotes: true
  removeRedundantAttributes: true
  useShortDoctype: true
  removeEmptyAttributes: true

isError = (props) -> Error404 in props.components

renderHTML = (store, props)->
  component =
    <Provider store={store}>
      <RouterContext {...props} />
    </Provider>

  minify(renderToString(component), MINIFY_OPTIONS)


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
      content = renderHTML(createStore(createMemoryHistory()), props)

      res.status(status)
      res.render('index', { content })
    )

