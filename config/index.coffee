fs = require('fs')
_ = require('lodash')

pkg = require('../package')

nodeEnv = process.env.NODE_ENV or 'development'


readConfigs = (path) ->
  envConfPath = "#{__dirname}/#{nodeEnv}.coffee"

  confs = [require("#{__dirname}/default.coffee")]
  confs.push(require(envConfPath)) if fs.existsSync(envConfPath)

  confs

base =
  environment: nodeEnv
  debug: nodeEnv is 'development' and not ('build' in process.argv)
  client: version: pkg.version

module.exports = _.merge(base, readConfigs('./')...)
