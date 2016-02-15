_ = require('lodash')
Router = require('express').Router

HTTP_TYPES = ['get', 'post', 'head', 'put', 'delete', 'all']


module.exports = class Controller
  constructor: ->
    @router = Router()

    for type in HTTP_TYPES
      @[type] = (route, callbacks...) ->
        bound = for callback in callbacks
          callback.bind(@)

        @router[type](route, bound...)

  use: (app)->
    @attachRoutes?()
    app.use(@router)
