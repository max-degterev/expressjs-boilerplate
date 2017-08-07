require('./modules/polyfills')

React = require('react')
{ render } = require('react-dom')

Router = require('react-router/lib/Router')
browserHistory = require('react-router/lib/browserHistory')
match = require('react-router/lib/match')

{ Provider } = require('react-redux')
{ trigger } = require('redial')

isEmpty = require('lodash/isEmpty')

require('fastclick')(document.body)

createStore = require('./store')
createRouter = require('./modules/routes')
{ getRoutesParams } = require('./modules/routes/utils')

{ setError } = require('./components/errorhandler/state').actions
{ setRoute } = require('./modules/routes/state').actions

// Router setup. Accepts history and routes.
// Both history and routes are relying on store and dispatching events.
renderPage = (store, history, routes) ->
  node =
    <Provider store={store}>
      <Router history={history} routes={routes} />
    </Provider>

  render(node, document.getElementById('main'))

startRouter = (store, history) ->
  hasInitialData = not isEmpty(__appState__)

  { subscribeRouter, routes } = createRouter(store)
  previousComponents = []

  handleFetch = (location) ->
    matchPage = (error, redirect, props) ->
      shouldFetch = not hasInitialData
      hasInitialData = false

      return handleError(error) if error
      return if redirect

      getLocals = (component) ->
        isFirstRender: previousComponents.indexOf(component) is -1
        location: props.location
        params: props.params
        dispatch: store.dispatch
        state: store.getState()
        route: getRoutesParams(props.routes)

      handleError = (error) -> store.dispatch(setError(error))

      trigger('fetch', props.components, getLocals).catch(handleError) if shouldFetch
      trigger('defer', props.components, getLocals).catch(handleError)
      previousComponents = props.components

    store.dispatch(setRoute(location.pathname))
    match({ routes, location, history }, matchPage)

  // React router doesn't allow for a dynamic routing configuration.
  // Custom "dynamic" routing can be implemented:
  //   1. Unmount currently mounted router
  //   2. Mount new router with new routing configuration
  //
  // This leads to errors with active components being unmounted at wrong moments.
  if not __appState__.error or __appState__.error.statusCode is 404
    subscribeRouter?()
    history.listen(handleFetch)
    handleFetch(history.getCurrentLocation())

  renderPage(store, history, routes)



// Call setup functions. First setup store, then initialize router.
store = createStore(__appState__)
startRouter(store, browserHistory)
