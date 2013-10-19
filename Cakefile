# =======================================================================================
# Dependencies and constants
# =======================================================================================
logPrefix = "[Cake]:"

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
log = (data)->
  print(data.toString())

warn = (data)->
  process.stderr.write(data.toString())

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
        console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Failed to fetch latest version for #{lib} with an error: #{error}")

  _checkVersion(lib, version) for lib, version of list

npmInstall = (callb)->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Updating npm dependency tree")

  exec 'npm install', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Dependencies installation failed with an error: #{error}")

bowerInstall = (callb)->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Updating bower dependency tree")

  exec 'bower install', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Dependencies installation failed with an error: #{error}")

compileGrunt = (callb)->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Executing grunt defaults")

  exec 'grunt', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Grunt defaults failed with an error: #{error}")

buildGrunt = (callb)->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Executing grunt build")

  exec 'grunt build', (error, stdout, stderr) ->
    unless error
      callb?()
    else
      console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Grunt build failed with an error: #{error}")

watchCoffee = ->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Spawning coffeescript watcher")

  coffee = spawn('coffee', ['-c', '-w', 'app/server/', 'app/shared/', "#{SERVER_FILE}.coffee"])
  coffee.stdout.on('data', log)
  coffee.stderr.on('data', warn)

watchGrunt = ->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Spawning grunt watcher")

  grunt = spawn('grunt', ['watch'])
  grunt.stdout.on('data', log)
  grunt.stderr.on('data', warn)

# startDatabase = (debug)->
#   console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Spawning redis")

#   redis = spawn('redis-server', ['/usr/local/etc/redis.conf'])
#   redis.stdout.on('data', log)
#   redis.stderr.on('data', warn)

startServer = (debug)->
  watchCoffee()
  watchGrunt()
  # startDatabase()

  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Starting server")

  params = "NODE_ENV=development NODE_CONFIG_DISABLE_FILE_WATCH=Y " +
    "nodemon -w app/server/ -w app/shared/ -w config/ -w views/server/ -w views/shared/ -w #{SERVER_FILE}.js" +
    (if debug then " --debug" else "") + " #{SERVER_FILE}.js"

  setTimeout ->
    nodemon = exec(params)
    nodemon.stdout.on('data', log)
    nodemon.stderr.on('data', warn)
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

  mailer.sendMail mailOptions, (error, status)->
    console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Sendmail failed with an error: #{error}") if error

# =======================================================================================
# Tasks
# =======================================================================================
task 'versions', '[DEV]: Check package.json versions state', ->
  checkVersions(require('./package').dependencies)

task 'install', '[DEV]: Install all dependencies', ->
  npmInstall bowerInstall

task 'coffee', '[DEV]: Watch and compile serverside coffee', ->
  watchCoffee()

task 'grunt', '[DEV]: Watch and compile clientside assets', ->
  watchGrunt()

task 'dev', '[DEV]: Devserver with autoreload', ->
  npmInstall ->
    bowerInstall ->
      compileGrunt ->
        startServer()

task 'debug', '[DEV]: Devserver with autoreload and debugger', ->
  npmInstall ->
    bowerInstall ->
      compileGrunt ->
        startServer(true)

task 'deploy', '[LOCAL]: Update PRODUCTION state from the repo and restart the server', ->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Connecting to VPS #{VPS_USER}@#{VPS_HOST} && running postdeploy")
  exec "ssh #{VPS_USER}@#{VPS_HOST} 'cd #{VPS_HOME} && cake postdeploy'",
    (error, stdout, stderr) ->
      unless error
        console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Triggered deploy, wait for email confirmation 👍")
      else
        console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Deploy failed with an error: #{error}")

task 'push', '[LOCAL]: Update PRODUCTION state from the repo without restarting the server', ->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Connecting to VPS #{VPS_USER}@#{VPS_HOST} && running postpush")
  exec "ssh #{VPS_USER}@#{VPS_HOST} 'cd #{VPS_HOME} && cake postpush'",
    (error, stdout, stderr) ->
      unless error
        console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Triggered publish, wait for email confirmation 👍")
      else
        console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Publish failed with an error: #{error}")

task 'postdeploy', '[PROD]: Update current app state from the repo and restart the server', ->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Pulling updates from the repo")
  exec 'git pull', (error, stdout, stderr) ->
    unless error
      npmInstall ->
        buildGrunt ->
          console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Restarting forever")
          exec("forever restartall")
          sendMail()

    else
      console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Git pull failed with an error: #{error}")

task 'postpush', '[PROD]: Update current app state from the repo', ->
  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Pulling updates from the repo")
  exec 'git pull', (error, stdout, stderr) ->
    unless error
      sendMail('push')
    else
      console.warn("[#{(new Date()).toUTCString()}] #{logPrefix} Git pull failed with an error: #{error}")

task 'forever', '[PROD]: Start server in PRODUCTION environmont', ->
  server = "NODE_ENV=production NODE_CONFIG_DISABLE_FILE_WATCH=Y " +
    "forever start -l #{VPS_LOG}/#{SERVER_FILE}.log --append " +
    "--sourceDir #{VPS_HOME} #{SERVER_FILE}.js"

  console.log("[#{(new Date()).toUTCString()}] #{logPrefix} Starting server: #{server}")
  exec(server)
