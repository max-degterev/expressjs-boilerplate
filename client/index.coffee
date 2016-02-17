React = require('react')
ReactDOM = require('react-dom')

createStore = require('./modules/store')
Router = require('./modules/router')


ReactDOM.render(<Router store={createStore()} />, document.getElementById('main'))
