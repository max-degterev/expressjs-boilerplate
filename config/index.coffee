fs = require('fs')
merge = require('lodash/merge')
{ version } = require('../package')


getConfigs = (paths) ->
  for path in paths
    continue unless fs.existsSync(path)
    require(path)

nodeEnv = process.env.NODE_ENV or 'development'
isDebug = nodeEnv is 'development' and not ('build' in process.argv)
isSandbox = process.env.SANDBOX is 'true' or isDebug

base =
  environment: nodeEnv
  debug: isDebug
  sandbox: isSandbox
  client: { version }

overrides = getConfigs([
  "#{__dirname}/default.coffee"
  "#{__dirname}/#{nodeEnv}.coffee"
  "#{__dirname}/local.coffee"
])

module.exports = merge(base, overrides...)
