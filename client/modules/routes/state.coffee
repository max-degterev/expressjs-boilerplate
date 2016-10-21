types =
  ROUTE_SET: 'ROUTE_SET'

actions =
  setRoute: (payload) -> { type: types.ROUTE_SET, payload }

reducer = (state = null, action) ->
  switch action.type
    when types.ROUTE_SET
      action.payload
    else
      state

module.exports = { types, actions, reducer }
