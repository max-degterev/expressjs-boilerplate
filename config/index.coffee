fs = require('fs')

_ = require('underscore')
_.mixin(deepExtend: require('underscore-deep-extend')(_))

nodeEnv = process.env.NODE_ENV or 'development'

readConfigs = (path) ->
  envConfPath = "#{__dirname}/#{path}/#{nodeEnv}.coffee"

  confs = [require("#{__dirname}/#{path}/default.coffee")]
  confs.push(require(envConfPath)) if fs.existsSync(envConfPath)

  confs

defaults =
  env: nodeEnv
  debug: nodeEnv is 'development'

config = _.deepExtend(defaults, readConfigs('./')...)

unless config.base_url
  config.base_url = "http://#{ config.host or config.server.ip }"
  config.base_url += ":#{ config.server.port }" if config.debug

module.exports = config
