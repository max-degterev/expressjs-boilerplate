React = require('react')
ReactDOM = require('react-dom')

{ browserHistory } = require('react-router')

createStore = require('./modules/store')
Root = require('./modules/router')


ReactDOM.render(<Root store={createStore(browserHistory)} />, document.getElementById('main'))
