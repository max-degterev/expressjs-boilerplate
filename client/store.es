config = require('uni-config')
{ createStore, applyMiddleware, combineReducers } = require('redux')


reducers =
  route: require('./modules/routes/state').reducer
  error: require('./components/errorhandler/state').reducer

middleware = [
  require('redux-thunk').default
]

if config.debug
  middleware.push(require('redux-immutable-state-invariant').default())

if config.sandbox
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

  { createLogger } = require('redux-logger')
  middleware.push(createLogger(loggerOptions))

module.exports = (initialState) ->
  createStore(combineReducers(reducers), initialState, applyMiddleware(middleware...))
