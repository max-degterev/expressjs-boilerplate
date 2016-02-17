{ createStore, applyMiddleware, combineReducers } = require('redux')

{ syncHistory, routeReducer } = require('react-router-redux')
thunk = require('redux-thunk')

rootReducer = combineReducers({ routing: routeReducer })


module.exports = (history, initialState) ->
  createStore(rootReducer, initialState,
    applyMiddleware(thunk, syncHistory(history))
  )
