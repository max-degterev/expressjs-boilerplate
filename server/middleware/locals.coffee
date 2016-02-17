_ = require('lodash')


module.exports = ->
  (req, res, next) ->
    locals =
      config: require('config')
      asset: require('../../build/assetmanager')
      serialize: require('serialize-javascript')

    _.assignIn(res.locals, locals)
    next()
