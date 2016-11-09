require('./polyfills')
require('./es6_test_remove_me').default()

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
createRouter = require('./router')

{ setRoute } = require('./modules/routes/state').actions

startSession = (store) ->
  store.dispatch(setRoute(global.location.pathname))

renderPage = (store, history, routes) ->
  Component =
    <Provider store={store}>
      <Router history={history} routes={routes} />
    </Provider>

  render(Component, document.getElementById('main'))

startRouter = (store, history) ->
  hasInitialData = not isEmpty(__appState__)

  routes = createRouter(store)
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

      handleError = (error) -> console.error(error)

      trigger('fetch', props.components, getLocals).catch(handleError) if shouldFetch
      trigger('defer', props.components, getLocals).catch(handleError)
      previousComponents = props.components

    store.dispatch(setRoute(location.pathname))
    match({ routes, location }, matchPage)

  history.listen(handleFetch)
  handleFetch(history.getCurrentLocation())
  renderPage(store, history, routes)


###
  Call setup functions. First setup store, then initialize router.
###
store = createStore(__appState__)
startSession(store)
startRouter(store, browserHistory)
