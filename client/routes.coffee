React = require('react')
{ Route } = require('react-router')

Error404 = require('./containers/error')
Home = require('./containers/home')


module.exports =
  <Route>
    <Route path="/" component={Home} />
    <Route path="*" component={Error404} />
  </Route>
