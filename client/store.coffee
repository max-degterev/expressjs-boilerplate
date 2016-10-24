config = require('config')

{ createStore, applyMiddleware, combineReducers } = require('redux')
createLogger = require('redux-logger')

reducers =
  route: require('./modules/routes/state').reducer

middleware = [
  require('redux-thunk').default
]

if config.debug
  middleware.push(require('redux-immutable-state-invariant')())

  if not process.browser
    loggerOptions =
      duration: true
      colors: false
      level:
        prevState: -> false
        nextState: -> false
        action: -> 'log'
        error: -> 'error'
  else
    loggerOptions = duration: true

  middleware.push(createLogger(loggerOptions))

module.exports = (initialState) ->
  createStore(combineReducers(reducers), initialState, applyMiddleware(middleware...))
