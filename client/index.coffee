React = require('react')
ReactDOM = require('react-dom')

Router = require('./router')
createStore = require('./modules/store')

store = createStore()

ReactDOM.render(<Router store={store} />, document.getElementById('main'))
