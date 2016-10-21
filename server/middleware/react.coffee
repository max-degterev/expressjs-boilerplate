winston = require('winston')
config = require('config')

React = require('react')
{ renderToString } = require('react-dom/server')

match = require('react-router/lib/match')
RouterContext = require('react-router/lib/RouterContext')

{ Provider } = require('react-redux')
{ trigger } = require('redial')

createStore = require('../../client/store')
createRouter = require('../../client/router')

Error404 = require('../../client/containers/error_404').default
{ setRoute } = require('../../client/modules/routes/state').actions


isError404 = (props) -> Error404 in props.components

createComponent = (store, props) ->
  <Provider store={store}>
    <RouterContext {...props} />
  </Provider>

renderPage = (res, store, props) ->
  statusCode = if isError404(props) then 404 else 200
  res.status(statusCode)

  Component = createComponent(store, props)
  content = renderToString(Component)

  Object.assign(res.locals.state, store.getState())
  res.render('index', { content })

renderError = (res, store) ->
  state = store.getState()
  Object.assign(res.locals.state, state)

  res.status(state.error.statusCode or 500)
  res.render('index')

module.exports = ->
  (req, res, next) ->
    store = createStore()
    store.dispatch(setRoute(req.path))

    handleError = (error) ->
      winston.error("Request #{req.url} failed to fetch data:", error)
      renderError(res, store)

    matchPage = (error, redirect, props) ->
      if error
        winston.error("Request #{req.url} failed to route:", error.message)
        return next()

      if redirect
        return res.redirect(302, redirect.pathname + redirect.search)

      if not props # if there was no props, this request isn't handled by FE explicitly
        return next()

      locals =
        isFirstRender: true
        location: props.location
        params: props.params
        dispatch: store.dispatch
        state: store.getState()

      trigger('fetch', props.components, locals)
        .then(-> renderPage(res, store, props))
        .catch(handleError)


    routes = createRouter(store)
    match({ routes, location: req.url }, matchPage)
