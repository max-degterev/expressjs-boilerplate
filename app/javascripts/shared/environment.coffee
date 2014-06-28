class Environment
  attributes: global.app?.env or {}

  create: (req, res, next)=>
    @attributes = res.locals.env = {}
    next()

  restore: (res)->
    @attributes = res.locals.env or {}
    @

  set: (key, value)->
    if typeof key is 'string'
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
    for k, v of @attributes
      delete @attributes[k]
    @

  toJSON: -> @attributes

module.exports = new Environment
