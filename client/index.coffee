React = require('react')
ReactDOM = require('react-dom')

Router = require('./router')
# createStore = require('./modules/store')

# store = createStore()

# ReactDOM.render(<Root store={store} />, document.getElementById('main'))

ReactDOM.render(<Router />, document.getElementById('main'))
