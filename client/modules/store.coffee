{ createStore, applyMiddleware, combineReducers } = require('redux')
{ browserHistory } = require('react-router')

{ syncHistory, routeReducer } = require('react-router-redux')
thunk = require('redux-thunk')

rootReducer = combineReducers({ routing: routeReducer })


module.exports = (initialState) ->
  createStore(rootReducer, initialState,
    applyMiddleware(thunk, syncHistory(browserHistory))
  )
