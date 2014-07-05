config = require('config')
utils = require('./utils')
_ = require('underscore')
router = require('express').Router()


module.exports = class Controller
  # Please set this on the instance
  logPrefix: '[app.server.base.controller]:'


  # Class logic below
  constructor: (@options)->
    _.defaults(@, @options) if @options
    @_router = router

  _handler: (type, route, callbacks...)->
    boundCallbacks = @bind(callbacks)
    @_router[type](config.endpoints[route] or route, boundCallbacks...)

  get: (route, callbacks...)-> @_handler('get', route, callbacks...)
  post: (route, callbacks...)-> @_handler('post', route, callbacks...)
  head: (route, callbacks...)-> @_handler('head', route, callbacks...)
  put: (route, callbacks...)-> @_handler('put', route, callbacks...)
  delete: (route, callbacks...)-> @_handler('delete', route, callbacks...)
  all: (route, callbacks...)-> @_handler('all', route, callbacks...)

  use: (@app)->
    @middleware?()
    @modules?()
    @router?()

    @app.use(@_router)

    @log('initialized', 'yellow')

_.defaults(Controller::, utils)
module.exports = Controller
