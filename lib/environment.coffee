_ = require('lodash')


class Environment
  attributes: global.__appEnvironment__ or {}

  middleware: (req, res, next) =>
    @attributes = res.locals.__appEnvironment__ = {}
    next()

  set: (key, value) ->
    if _.isString(key)
      @attributes[key] = value
    else
      for k, v of key
        @attributes[k] = v
    @

  remove: (key) ->
    delete @attributes[key]
    @

  get: (key) -> @attributes[key]
  has: (key) -> !!@attributes[key]

  clear: ->
    @remove(key) for key of @attributes
    @

  clone: -> _.cloneDeep(@attributes)

  # Function to allow JSON.stringify calls
  toJSON: -> @clone()


module.exports = new Environment()
