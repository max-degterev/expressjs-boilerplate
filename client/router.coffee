React = require('react')
{ Provider } = require('react-redux')
{ Router, Route, browserHistory } = require('react-router')

Error = require('./containers/error')
Home = require('./containers/home')


module.exports = class Root extends React.Component
  render: ->
    <Router history={browserHistory}>
      <Route path="/" component={Home} />
      <Route path="*" component={Error} />
    </Router>


  # render: ->
  #   <Provider store={@props.store}>
  #     <Router history={browserHistory}>
  #       <Route path="/" component={Home} />
  #       <Route path="*" component={Error} />
  #     </Router>
  #   </Provider>
