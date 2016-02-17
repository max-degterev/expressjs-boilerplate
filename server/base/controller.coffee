_ = require('lodash')
Router = require('express').Router

HTTP_TYPES = ['get', 'post', 'head', 'put', 'delete', 'all']


module.exports = class Controller
  constructor: ->
    @router = Router()

    for type in HTTP_TYPES
      do (type) =>
        @[type] = (route, callbacks...) ->
          bound = for callback in callbacks
            throw new Error("Handler for '#{type.toUpperCase()} #{route}' of #{@constructor.name} Controller is not defined") unless callback
            callback.bind(@)

          @router[type](route, bound...)

  use: (app) ->
    @attachRoutes?()
    app.use(@router)
