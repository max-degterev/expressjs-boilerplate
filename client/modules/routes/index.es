config = require('uni-config')

React = require('react')
Route = require('react-router/lib/Route')

{ getRouteMatcher, getAuthorizedRoutes } = require('../../permissions')

createCommonRoutes = require('../sections/common')

{ validateParams, getLocationPath, setReferrer } = require('../utils')


LOGIN_URL = '/login'
knownRoutes = getAuthorizedRoutes()

createRoutes = (store) ->
  commonRoutes = createCommonRoutes().routes
  sandboxRoutes = require('../sections/sandbox')().routes if config.sandbox

  smartRedirect = (state, replace) ->
    referrer = getLocationPath(state.location)
    replace(setReferrer(LOGIN_URL, referrer))

  routeChecker = getRouteMatcher(knownRoutes, shouldBeMatched = true, smartRedirect)

  routes =
    <div>
      <Route path="/" component={require('../../../containers/home').default} />
      <Route path="/register(/:accessCode)" onEnter={validateParams('accessCode')} component={require('../../../containers/registration').default} />

      <Route path="/login" component={require('../../../containers/login').default} />
      <Route path="/magic-link/:token" component={require('../../../containers/magic_link').default} />

      {commonRoutes}
      {sandboxRoutes}

      <Route path="*" onEnter={routeChecker} component={require('../../../containers/error_404')} />
    </div>

  { routes }


module.exports = createRoutes
