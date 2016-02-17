React = require('react')
{ Provider } = require('react-redux')
{ Router, browserHistory } = require('react-router')

routes = require('../routes')


module.exports = class Root extends React.Component
  render: ->
    <Provider store={@props.store}>
      <Router history={browserHistory} routes={routes}/>
    </Provider>
