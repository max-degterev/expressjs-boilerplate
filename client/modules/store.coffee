{ createStore, applyMiddleware } = require('redux')
{ syncHistory } = require('react-router-redux')

{ browserHistory } = require('react-router')
thunk = require('redux-thunk')
rootReducer = require('../reducers')


module.exports = (initialState) ->
  createStore(rootReducer, initialState,
    applyMiddleware(thunk, syncHistory(browserHistory))
  )
