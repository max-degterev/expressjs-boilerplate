{ createStore, applyMiddleware, combineReducers } = require('redux')

{ routerReducer } = require('react-router-redux')
createLogger = require('redux-logger')

config = require('config')


reducers =
  routing: routerReducer
  # Add reducers here


middleware = [
  require('redux-thunk').default
  require('./modules/promise').middleware
]

if config.debug
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
