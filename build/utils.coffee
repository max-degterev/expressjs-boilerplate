_ = require('lodash')
chalk = require('chalk')


utils =
  pathNormalize: (path) ->
    "#{path.replace("#{__dirname}/../", '')}"

  sourcesNormalize: (paths) ->
    paths = [paths] if !_.isArray(paths)
    paths.map(utils.pathNormalize)

  benchmarkReporter: (action, startTime) ->
    console.log(chalk.magenta("#{action} in #{((Date.now() - startTime) / 1000).toFixed(2)}s"))

  watchReporter: (e) ->
    console.log(chalk.cyan("File #{utils.pathNormalize(e.path)} #{e.type}, flexing 💪"))

  errorReporter: (e) ->
    stack = e.stack or e
    console.log(chalk.bold.red("Build error!\n#{stack}"))

module.exports = utils
