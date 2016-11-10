{ spawn } = require('child_process')
chalk = require('chalk')

utils =
  pathNormalize: (path) ->
    "#{path.replace("#{__dirname}/../", '')}"

  sourcesNormalize: (paths) ->
    paths = [paths] if not Array.isArray(paths)
    paths.map(utils.pathNormalize)

  benchmarkReporter: (action, startTime) ->
    console.log(chalk.magenta("#{action} in #{((Date.now() - startTime) / 1000).toFixed(2)}s"))

  watchReporter: (e) ->
    console.log(chalk.cyan("File #{utils.pathNormalize(e.path)} #{e.type}, flexing 💪"))

  errorReporter: (e) ->
    console.log(chalk.bold.red("Build error!\n#{e.stack or e}"))

  run: (string) ->
    [ command, args... ] = string.split(' ')
    spawn(command, args, stdio: 'inherit')

module.exports = utils
