omit = require('lodash/omit')
assign = require('lodash/assign')

{ types } = require('../constants')

resolved = (type) -> "#{type}_#{types.RESOLVED}"
rejected = (type) -> "#{type}_#{types.REJECTED}"

middleware = (store) ->
  (next) ->
    (action) ->
      return next(action) unless action.promise
      { promise, type } = action

      newAction = assign(omit(action, 'promise'), { type })
      next(newAction)

      promise
        .then((payload) ->
          newAction = assign(omit(action, 'promise'), { type: resolved(type), payload })
          next(newAction)
        )
        .catch((payload) ->
          newAction = assign(omit(action, 'promise'), { type: rejected(type), payload })
          next(newAction)
        )

      promise

module.exports = { middleware, resolved, rejected }
