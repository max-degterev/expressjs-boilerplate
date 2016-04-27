fs = require('fs')
merge = require('lodash/merge')

version = require('../package').version

nodeEnv = process.env.NODE_ENV or 'development'
isDebug = nodeEnv is 'development' and not ('build' in process.argv)
isSandbox = process.env.SANDBOX is 'true' or isDebug

readConfigs = (path) ->
  envConfPath = "#{__dirname}/#{nodeEnv}.coffee"
  localConfPath = "#{__dirname}/local.coffee"

  confs = [require("#{__dirname}/default.coffee")]
  confs.push(require(envConfPath)) if fs.existsSync(envConfPath)
  confs.push(require(localConfPath)) if fs.existsSync(localConfPath)

  confs

base =
  environment: nodeEnv
  debug: isDebug
  sandbox: isSandbox
  client: { version }

module.exports = merge(base, readConfigs('./')...)
