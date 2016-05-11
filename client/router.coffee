React = require('react')

Route = require('react-router/lib/Route')
Redirect = require('react-router/lib/Redirect')


createRouter = (store) ->
  <Route>
    <Redirect from="/*/" to="/*" />

    <Route path="/" component={require('./containers/home')} />
    <Route path="*" component={require('./containers/error')} />
  </Route>

module.exports = createRouter
