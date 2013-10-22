# =======================================================================================
# Dependencies and constants
# =======================================================================================
logPrefix = '[Cake]:'

SERVER_FILE = 'app'

USER_NAME = 'Max Degterev'
USER_EMAIL = 'me@maxdegterev.name'

VPS_USER = 'maxdegterev'
VPS_HOST = 'maxdegterev.name'
VPS_HOME = '/var/www/maxdegterev'
VPS_LOG = '/var/log/maxdegterev'


{spawn, exec} = require 'child_process'
{print} = require 'sys'


# =======================================================================================
# Utility functions
# =======================================================================================
log = (message)-> console.log("[#{(new Date()).toUTCString()}] #{logPrefix} #{message}")
proxyLog = (data)-> print(data.toString())
proxyWarn = (data)-> process.stderr.write(data.toString())

checkVersions = (list)->
  sty = require('sty')

  _checkVersion = (lib, version)->
    exec "npm info #{lib} version", (error, stdout, stderr) ->
      unless error
        latest = stdout.replace('\n\n', '')
        current = version.replace(/[\<\>\=\~]*/, '')

        if current is latest
          console.log("#{sty.bold 'OK:'} #{lib} #{current}")
        else
          if current is '*'
            console.warn("#{sty.bold sty.cyan 'NOTICE:'} #{lib} version number not specified: #{current}, latest: #{latest}")
          else
            console.warn("#{sty.bold sty.red 'WARN:'} #{lib} needs to be updated, current: #{current}, latest: #{latest}")
      else
        log("Failed to fetch latest version for #{lib} with an error: #{error}")

  _checkVersion(lib, version) for lib, version of list

npmInstall = (callb)->
  log('Updating npm dependency tree')

  exec 'npm install', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      log("Dependencies installation failed with an error: #{error}")

bowerInstall = (callb)->
  log('Updating bower dependency tree')

  exec 'bower install', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      log("Dependencies installation failed with an error: #{error}")

compileGrunt = (callb)->
  log('Executing grunt defaults')

  exec 'grunt', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      log("Grunt defaults failed with an error: #{error}")

buildGrunt = (callb)->
  log('Executing grunt build')

  exec 'grunt build', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      log("Grunt build failed with an error: #{error}")

watchCoffee = ->
  log('Spawning coffeescript watcher')

  coffee = spawn('coffee', ['-c', '-w', 'app/server/', 'app/shared/', "#{SERVER_FILE}.coffee"])
  coffee.stdout.on('data', proxyLog)
  coffee.stderr.on('data', proxyWarn)

watchGrunt = ->
  log('Spawning grunt watcher')

  grunt = spawn('grunt', ['watch'])
  grunt.stdout.on('data', proxyLog)
  grunt.stderr.on('data', proxyWarn)

# startDatabase = (debug)->
#   log('Spawning redis')

#   redis = spawn('redis-server', ['/usr/local/etc/redis.conf'])
#   redis.stdout.on('data', proxyLog)
#   redis.stderr.on('data', proxyWarn)

startServer = (debug)->
  watchCoffee()
  watchGrunt()
  # startDatabase()

  log('Starting server')

  params = "NODE_ENV=development NODE_CONFIG_DISABLE_FILE_WATCH=Y " +
    "nodemon -w app/server/ -w app/shared/ -w config/ -w views/server/ -w views/shared/ -w #{SERVER_FILE}.js" +
    (if debug then " --debug" else "") + " #{SERVER_FILE}.js"

  setTimeout ->
    nodemon = exec(params)
    nodemon.stdout.on('data', proxyLog)
    nodemon.stderr.on('data', proxyWarn)
  , 1000

sendMail = (type = 'deploy')->
  mailer = require('nodemailer').createTransport('sendmail')
  pkg = require('./package')

  mailOptions =
    from: "\"#{USER_NAME}\" <#{USER_EMAIL}>"
    to: "\"#{USER_NAME}\" <#{USER_EMAIL}>"

  if type is 'deploy'
    mailOptions.subject = 'Your website has been deployed to the server'
    mailOptions.text = "Deploy of #{pkg.description} was successful, v#{pkg.version} @ #{(new Date).toString()}"
  else
    mailOptions.subject = 'Your website has been pushed to the server'
    mailOptions.text = "Push of #{pkg.description} was successful, v#{pkg.version} @ #{(new Date).toString()}"

  mailer.sendMail mailOptions, (error, status)-> log("Sendmail failed with an error: #{error}") if error

# =======================================================================================
# Tasks
# =======================================================================================
task 'versions', '[DEV]: Check package.json versions state', ->
  pkg = require('./package')
  for item in ['dependencies', 'devDependencies', 'peerDependencies']
    checkVersions(pkg[item]) if pkg[item]

task 'install', '[DEV]: Install all dependencies', ->
  npmInstall bowerInstall

task 'coffee', '[DEV]: Watch and compile serverside coffee', ->
  watchCoffee()

task 'grunt', '[DEV]: Watch and compile clientside assets', ->
  watchGrunt()

task 'dev', '[DEV]: Devserver with autoreload', ->
  npmInstall bowerInstall compileGrunt startServer

task 'debug', '[DEV]: Devserver with autoreload and debugger', ->
  npmInstall bowerInstall compileGrunt -> startServer(true)

task 'deploy', '[LOCAL]: Update PRODUCTION state from the repo and restart the server', ->
  log("Connecting to VPS #{VPS_USER}@#{VPS_HOST} && running postdeploy")
  exec "ssh #{VPS_USER}@#{VPS_HOST} 'cd #{VPS_HOME} && cake postdeploy'",
    (error, stdout, stderr) ->
      unless error
        log('Triggered deploy, wait for email confirmation 👍')
      else
        log("Deploy failed with an error: #{error}")

task 'push', '[LOCAL]: Update PRODUCTION state from the repo without restarting the server', ->
  log("Connecting to VPS #{VPS_USER}@#{VPS_HOST} && running postpush")
  exec "ssh #{VPS_USER}@#{VPS_HOST} 'cd #{VPS_HOME} && cake postpush'",
    (error, stdout, stderr) ->
      unless error
        log('Triggered publish, wait for email confirmation 👍')
      else
        log("Publish failed with an error: #{error}")

task 'postdeploy', '[PROD]: Update current app state from the repo and restart the server', ->
  log('Pulling updates from the repo')
  exec 'git pull', (error, stdout, stderr) ->
    unless error
      npmInstall buildGrunt ->
        log('Restarting forever')
        exec("forever restartall")
        sendMail()

    else
      log("Git pull failed with an error: #{error}")

task 'postpush', '[PROD]: Update current app state from the repo', ->
  log('Pulling updates from the repo')
  exec 'git pull', (error, stdout, stderr) ->
    unless error
      sendMail('push')
    else
      log("Git pull failed with an error: #{error}")

task 'forever', '[PROD]: Start server in PRODUCTION environmont', ->
  server = "NODE_ENV=production NODE_CONFIG_DISABLE_FILE_WATCH=Y " +
    "forever start -l #{VPS_LOG}/#{SERVER_FILE}.log --append " +
    "--sourceDir #{VPS_HOME} #{SERVER_FILE}.js"

  log("Starting server: #{server}")
  exec(server)
