require('core-js/es6/object')
require('core-js/es6/array')
require('core-js/es6/promise')

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
  isFirstLoad = true

  routes = createRouter(store)
  previousComponents = []

  handleFetch = (location) ->
    matchPage = (error, redirect, props) ->
      getLocals = (component) ->
        isFirstRender: previousComponents.indexOf(component) is -1
        location: props.location
        params: props.params
        dispatch: store.dispatch
        state: store.getState()

      handleError = (error) -> console.error(error)

      store.dispatch(setRoute(location.pathname)) unless isFirstLoad
      return handleError(error) if error

      trigger('fetch', props.components, getLocals).catch(handleError) unless hasInitialData
      trigger('defer', props.components, getLocals).catch(handleError)
      hasInitialData = false
      isFirstLoad = false
      previousComponents = props.components

    match({ routes, location }, matchPage)

  renderPage(store, history, routes)
  history.listen(handleFetch)


###
  Call setup functions. First setup store, then initialize router.
###
store = createStore(__appState__)
startSession(store)
startRouter(store, browserHistory)
