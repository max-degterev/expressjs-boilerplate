assign = require('lodash/assign')
config = require('config')


module.exports = ->
  (req, res, next) ->
    locals = {
      config,
      pretty: config.debug # used by Jade to have unminified output

      state: {}

      pick: require('lodash/pick')
      asset: require('../../build/assetmanager')
      serialize: require('serialize-javascript')
    }

    assign(res.locals, locals)
    next()
