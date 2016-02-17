React = require('react')
ReactDOM = require('react-dom')

createStore = require('./modules/store')
Root = require('./modules/router')


ReactDOM.render(<Root store={createStore()} />, document.getElementById('main'))
