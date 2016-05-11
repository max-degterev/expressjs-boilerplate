{ Router } = require('express')

HTTP_TYPES = ['get', 'post', 'head', 'put', 'delete', 'all']

injectHelpers = (controller) ->
  for type in HTTP_TYPES
    do (type) =>
      controller[type] = (route, callbacks...) ->
        bound = for callback in callbacks
          throw new Error("'#{type} #{route}' handler is undefined") unless callback
          callback.bind(controller)

        @router[type](route, bound...)


class BaseController
  constructor: ->
    @router = Router()
    injectHelpers(@)

  use: (app) ->
    @attachRoutes?()
    app.use(@router)

module.exports = BaseController
