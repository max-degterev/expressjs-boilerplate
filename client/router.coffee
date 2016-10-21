React = require('react')
Route = require('react-router/lib/Route')


createRouter = (store) ->
  <div>
    <Route path="/" component={require('./containers/home').default} />
    <Route path="*" component={require('./containers/error_404').default} />
  </div>

module.exports = createRouter
