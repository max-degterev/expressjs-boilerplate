_ = require('lodash')

class Environment
  attributes: global.app?.env or {}

  create: (req, res, next)=>
    @attributes = res.locals.env = {}
    next()

  set: (key, value)->
    if _.isString(key)
      @attributes[key] = value
    else
      for k, v of key
        @attributes[k] = v
    @

  unset: (key)->
    delete @attributes[key]
    @

  get: (key)-> @attributes[key]
  has: (key)-> !!@attributes[key]

  clear: ->
    @unset(key) for key of @attributes
    @

  toJSON: -> _.clone(@attributes)

module.exports = new Environment
