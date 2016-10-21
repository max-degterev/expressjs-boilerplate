config = require('config')
pick = require('lodash/pick')
asset = require('../../build/assetmanager')
serialize = require('serialize-javascript')


module.exports = ->
  (req, res, next) ->
    locals = {
      pretty: config.debug # used by Pug to have unminified output
      state: {}

      config
      pick
      asset
      serialize
    }

    Object.assign(res.locals, locals)
    next()
