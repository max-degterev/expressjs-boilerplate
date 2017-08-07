config = require('uni-config')

types =
  ERROR_SET: 'ERROR_SET'

actions =
  setError: (payload) ->
    console.error(payload.stack) if config.debug and payload instanceof Error
    { type: types.ERROR_SET, payload }

reducer = (state = null, action) ->
  switch action.type
    when types.ERROR_SET
      action.payload
    else
      state

module.exports = { types, actions, reducer }
