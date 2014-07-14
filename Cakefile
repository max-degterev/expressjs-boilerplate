{exec, spawn} = require('child_process')


# ========================================================================================
# Settings
# ========================================================================================
logPrefix = '[Cake]:'
SERVER_FILE = 'server'
APPLICATION_NAME = 'application'

USER_NAME = 'Awesome Person'
USER_EMAIL = 'me@example.com'

VPS_USER = 'application'
VPS_HOST = 'example.com'
VPS_HOME = '/var/www/application'
VPS_LOG = '/var/log/application'

envParams =
  NODE_CONFIG_DISABLE_FILE_WATCH: 'Y'
  NODE_CONFIG_PERSIST_ON_CHANGE: 'N'
  NODE_ENV: 'development'

option('-t', '--task [NAME]', 'Task to run gulp with, ex.: cake -t browserify gulp')

# If you add things here, don't forget to also update your .gitignore
# Entire node_modules folder is ignored by default
SYMLINKS = [
  'node_modules:../app/:app'
  'node_modules:../app/javascripts/shared/environment.coffee:env.coffee'
]


# More styles here: https://github.com/Marak/colors.js/blob/master/colors.js
STYLES =
  bold: ['\x1B[1m', '\x1B[22m']
  italic: ['\x1B[3m', '\x1B[23m']

  blue: ['\x1B[34m', '\x1B[39m']
  cyan: ['\x1B[36m', '\x1B[39m']
  green: ['\x1B[32m', '\x1B[39m']
  magenta: ['\x1B[35m', '\x1B[39m']
  red: ['\x1B[31m', '\x1B[39m']
  yellow: ['\x1B[33m', '\x1B[39m']


# ========================================================================================
# Utility functions
# ========================================================================================
proxy = (runner, callback)->
  # end: false means when runner died, don't kill process stream
  runner.stdout.pipe(process.stdout, end: false)
  runner.stderr.pipe(process.stderr, end: false)
  process.stdin.pipe(runner.stdin) # for nodemon etc to work
  runner.on('exit', (status)-> if status is 0 then callback?() else process.exit(status))

proxyLog = (runner)->
  runner.stdout.on('data', (data)-> process.stdout.write(data.toString()))
  runner.stderr.on('data', (data)-> process.stderr.write(data.toString()))

stylize = (string, style)-> "#{STYLES[style][0]}#{string}#{STYLES[style][1]}"

log = (message, styles)->
  if styles
    styles = styles.split(' ')
    message = stylize(message, style) for style in styles

  console.log("[#{(new Date).toUTCString()}] #{logPrefix} #{message}")

getEnvString = ->
  arr = for key, value of envParams
    "#{key}=#{value}"

  arr.join(' ')


# ========================================================================================
# Regular tasks logic
# ========================================================================================
checkNpmVersions = (name, list)->
  log("Checking #{name} NPM versions")

  _checkVersion = (lib, version)->
    exec "npm info #{lib} version", (error, stdout, stderr)->
      unless error
        latest = stdout.replace('\n\n', '')
        current = version.replace(/[\<\>\=\~]*/, '')

        if current is latest
          log("NPM OK: #{lib} #{current}")
        else
          if current is '*'
            log("NPM NOTICE: #{lib} version number not specified: #{current}, latest: #{latest}", 'cyan')
          else
            log("NPM WARN: #{lib} needs to be updated, current: #{current}, latest: #{latest}", 'red bold')
      else
        log("NPM Failed to fetch latest version for #{lib}", 'red bold')

  _checkVersion(lib, version) for lib, version of list

cleanNodeModules = (callb)->
  log('Removing node_modules folder')
  nodeModulesLocation = "#{__dirname}/node_modules"

  commands = [
    "rm -rf #{nodeModulesLocation}"
    "mkdir #{nodeModulesLocation}"
  ]

  log(command, 'red') for command in commands

  runner = exec commands.join(';'), (error, stdout, stderr)->
    unless error
      callb?()
    else
      log("Couldn't remove node_modules folder: #{error}", 'red bold')

  proxyLog(runner)

createSymlinks = (callb)->
  log('Creating symlinks')

  commands = for link in SYMLINKS
    [target, location, name] = link.split(':')
    cwd = "#{__dirname}/#{target}"
    "cd #{cwd}; ln -s \"#{location}\" \"#{name}\""

  log(command, 'cyan') for command in commands

  runner = exec commands.join(';'), (error, stdout, stderr)->
    unless error
      callb?()
    else
      log("Couldn't create symlinks: #{error}", 'red bold')

  proxyLog(runner)

deleteSymlinks = (callb)->
  log('Deleting symlinks')

  commands = for link in SYMLINKS
    [target, location, name] = link.split(':')
    link = "#{__dirname}/#{target}/#{name}"
    "rm #{link}"

  log(command, 'red') for command in commands

  runner = exec commands.join(';'), (error, stdout, stderr)->
    unless error
      callb?()
    else
      log("Couldn't delete symlinks: #{error}", 'red bold')

  proxyLog(runner)

npmInstall = (callb)->
  log('Updating npm dependencies')

  runner = exec 'npm install --loglevel http', (error, stdout, stderr)->
    unless error
      callb?()
    else
      log("Npm dependencies installation failed with an error: #{error}", 'red bold')

  proxyLog(runner)

compileGulp = (task, callb)->
  log("Executing gulp #{task or ''}")

  command = getEnvString()
  command += ' ./node_modules/.bin/gulp'
  command += " #{task}" if task

  log(command, 'cyan')

  runner = exec command, (error, stdout, stderr)-> callb?() unless error
  proxyLog(runner)

watchGulp = ->
  log('Starting gulp watcher')

  command = getEnvString()
  command += ' ./node_modules/.bin/gulp watch'

  log(command, 'cyan')

  runner = exec(command)
  proxy(runner)

startServer = (options = {})->
  log('Starting node')
  watchGulp() unless (options.skipwatch or options.skipassets)

  command = getEnvString()
  command += if options.skipwatch then ' coffee' else ' nodemon'
  command += ' --debug' if options.debug
  command += " #{SERVER_FILE}.coffee"

  log(command, 'cyan')

  runner = exec(command)
  proxy(runner)

startForever = ->
  log('Starting forever')

  options = [
    "-l #{VPS_LOG}/#{SERVER_FILE}.log --append"
    '--minUptime 1000'
    '--spinSleepTime 1000'
    "--sourceDir #{VPS_HOME}"
    "--uid \"#{APPLICATION_NAME}\""
    '-c coffee'
  ]

  command = getEnvString()
  command += ' forever start'
  command += " #{options.join(' ')}"
  command += " #{SERVER_FILE}.coffee"

  log(command, 'cyan bold')
  runner = exec(command)
  proxyLog(runner)

sendMail = (type = 'deploy')->
  mailer = require('nodemailer').createTransport('sendmail')
  pkg = require('./package')

  mailOptions =
    from: "\"#{USER_NAME}\" <#{USER_EMAIL}>"
    to: "\"#{USER_NAME}\" <#{USER_EMAIL}>"

  if type is 'deploy'
    mailOptions.subject = 'Your website has been deployed to the server'
    mailOptions.text = "Deploy of #{pkg.name} (#{pkg.description}) was successful, v#{pkg.version} @ #{(new Date).toString()}"
  else
    mailOptions.subject = 'Your website has been pushed to the server'
    mailOptions.text = "Push of #{pkg.name} (#{pkg.description}) was successful, v#{pkg.version} @ #{(new Date).toString()}"

  mailer.sendMail(mailOptions, (error, status)-> log("Sendmail failed with an error: #{error}", 'red bold') if error)


# =======================================================================================
# Tasks
# =======================================================================================
task 'versions', '[DEV]: Check package.json versions', ->
  pkg = require('./package')
  for item in ['dependencies', 'devDependencies', 'peerDependencies']
    checkNpmVersions(item, pkg[item]) if pkg[item]

task 'clean', '[DEV]: Remove node_modules and create system symlinks', ->
  cleanNodeModules -> createSymlinks()

task 'link', '[DEV]: Create system symlinks', -> createSymlinks()
task 'unlink', '[DEV]: Delete system symlinks', -> deleteSymlinks()
task 'relink', '[DEV]: Re-create system symlinks', ->
  deleteSymlinks -> createSymlinks()

task 'reinstall', '[DEV]: Clean all and install all dependencies anew', ->
  cleanNodeModules -> createSymlinks -> npmInstall()

task 'gulp', '[DEV]: Compile assets with local gulp, options: [-t]', (options)->
  compileGulp(options.task)

task 'dev', '[DEV]: Devserver with autoreload', -> startServer()
task 'debug', '[DEV]: Devserver with autoreload and debugger', -> startServer(debug: true)

task 'dev:skipwatch', '[DEV]: Devserver without autoreload', ->
  compileGulp null, -> startServer(skipwatch: true)
task 'dev:skipassets', '[DEV]: Devserver without assets compilation', ->
  startServer(skipassets: true)
task 'dev:skipall', '[DEV]: Devserver without autoreload and assets compilation', ->
  startServer(skipwatch: true, skipassets: true)

task 'prod', '[DEV]: Fake PRODUCTION environment for testing', ->
  envParams['NODE_ENV'] = 'production'
  compileGulp 'clean', -> compileGulp 'build', -> startServer(skipwatch: true)

task 'forever', '[PROD]: Start all applications with forever in production environment', ->
  envParams['NODE_ENV'] = 'production'
  startForever()

task 'deploy', '[LOCAL]: Update PRODUCTION state from the repo and restart the server', ->
  log("Connecting to VPS #{VPS_USER}@#{VPS_HOST} && running deploy:action")
  runner = exec "ssh #{VPS_USER}@#{VPS_HOST} 'cd #{VPS_HOME} && cake deploy:action'",
    (error, stdout, stderr)->
      unless error
        log('Deploy complete, wait for email confirmation 👍', 'cyan')
      else
        log("Deploy failed with an error: #{error}", 'red bold')

  proxyLog(runner)

task 'push', '[LOCAL]: Update PRODUCTION state from the repo without restarting the server', ->
  log("Connecting to VPS #{VPS_USER}@#{VPS_HOST} && running push:action")
  runner = exec "ssh #{VPS_USER}@#{VPS_HOST} 'cd #{VPS_HOME} && cake push:action'",
    (error, stdout, stderr)->
      unless error
        log('Push complete, wait for email confirmation 👍', 'cyan')
      else
        log("Push failed with an error: #{error}", 'red bold')

  proxyLog(runner)

task 'deploy:action', '[REMOTE]: Update current app state from the repo and restart the server', ->
  log('Pulling updates from the repo')

  runner1 = exec("forever stop #{APPLICATION_NAME}")
  runner2 = exec 'git pull', (error, stdout, stderr)->
    unless error
      npmInstall -> compileGulp 'clean', -> compileGulp 'build', ->
        log('Restarting forever', 'cyan')
        runner3 = exec('cake forever')

        sendMail('deploy')
        proxyLog(runner3)

    else
      log("Git pull failed with an error: #{error}", 'red bold')

  proxyLog(runner1)
  proxyLog(runner2)

task 'push:action', '[REMOTE]: Update current app state from the repo', ->
  log('Pulling updates from the repo')
  runner = exec 'git pull', (error, stdout, stderr)->
    unless error
      sendMail('push')
    else
      log("Git pull failed with an error: #{error}", 'red bold')

  proxyLog(runner)
