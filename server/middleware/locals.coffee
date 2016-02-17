_ = require('lodash')
config = require('config')


module.exports = ->
  (req, res, next) ->
    locals = {
      _, config,
      pretty: config.debug # used by Jade to have unminified output
      asset: require('../../build/assetmanager')
      serialize: require('serialize-javascript')
    }

    _.assignIn(res.locals, locals)
    next()
