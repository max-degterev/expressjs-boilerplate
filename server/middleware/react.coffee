winston = require('winston')
config = require('config')

assign = require('lodash/assign')

React = require('react')
{ renderToString } = require('react-dom/server')

match = require('react-router/lib/match')
RouterContext = require('react-router/lib/RouterContext')

{ Provider } = require('react-redux')
{ trigger } = require('redial')

createStore = require('../../client/store')
createRouter = require('../../client/router')

Error = require('../../client/containers/error')
isError = (props) -> Error in props.components

createComponent = (store, props) ->
  <Provider store={store}>
    <RouterContext {...props} />
  </Provider>

renderPage = (res, store, props) ->
  status = if isError(props) then 404 else 200
  res.status(status)

  Component = createComponent(store, props)
  content = renderToString(Component)

  assign(res.locals.state, store.getState())
  res.render('index', { content })

renderError = (res, store, error) ->
  res.status(error.status)

  assign(res.locals.state, store.getState())
  res.render('index')

module.exports = ->
  (req, res, next) ->
    store = createStore()

    handleError = (error) ->
      status = 500
      payload = { status, error }

      winston.error("Request #{req.url} failed to fetch data:", error)
      renderError(res, store, { status, payload })

    matchPage = (error, redirect, props) ->
      if error
        winston.error("Request #{req.url} failed to route:", error.message)
        return next()

      if redirect
        return res.redirect(302, redirect.pathname + redirect.search)

      if not props # if there was no props, this request isn't handled by FE explicitly
        return next()

      locals =
        location: props.location
        params: props.params
        dispatch: store.dispatch

      trigger('fetch', props.components, locals)
        .then(-> renderPage(res, store, props))
        .catch(handleError)

    routes = createRouter(store)
    match({ routes, location: req.url }, matchPage)
