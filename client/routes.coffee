React = require('react')
{ Route } = require('react-router')

Error = require('./containers/error')
Home = require('./containers/home')


module.exports =
  <Route>
    <Route path="/" component={Home} />
    <Route path="*" component={Error} />
  </Route>
