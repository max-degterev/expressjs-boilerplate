{exec, spawn} = require('child_process')
log = require('./app/common/logger').bind(logPrefix: '[Cake]:')


# ========================================================================================
# Settings
# ========================================================================================
APPLICATION_NAME = 'application'
SERVER_FILE = 'server'

VPS_USER = APPLICATION_NAME
VPS_HOST = 'example.com'
VPS_HOME = "/var/www/#{APPLICATION_NAME}"
VPS_LOG = "/var/log/#{APPLICATION_NAME}"

envParams = NODE_ENV: 'development'
option('-t', '--task [NAME]', 'Task to run gulp with, ex.: cake -t browserify gulp')


# If you add things here, don't forget to also update your .gitignore
# Entire node_modules folder is ignored by default
SYMLINKS = [
  'node_modules:../app/:app'
  'node_modules:../config/:config'
  'node_modules:../app/common/environment.coffee:env.coffee'
  'node_modules:../templates/:templates'
  'node_modules:../stylesheets/:stylesheets'
  'node_modules:../vendor/:vendor'
]


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

getEnvString = ->
  arr = for key, value of envParams
    "#{key}=#{value}"

  arr.join(' ')


# ========================================================================================
# Regular tasks logic
# ========================================================================================
checkNpmVersions = (list)->
  _checkVersion = (lib, version)->
    if !!~version.indexOf('#')
      notice = "NPM NOTICE: #{lib} using github repo http://github.com/#{version.split('#')[0]}, "
      notice += "loaded: #{version.split('#')[1]}, latest: check manually"
      return log(notice, 'cyan')

    exec "npm info #{lib} version", (error, stdout, stderr)->
      unless error
        latest = stdout.replace(/[\r\n]+/, '')
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

createSymlinks = (callb) ->
  log('Creating symlinks')

  commands = for link in SYMLINKS
    [target, location, name] = link.split(':')
    cwd = "#{__dirname}/#{target}"
    "cd #{cwd}; test -s \"#{name}\" || ln -s \"#{location}\" \"#{name}\""

  commands.unshift('mkdir -p node_modules')

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

startServer = (options = {}) ->
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


# =======================================================================================
# Tasks
# =======================================================================================
task 'logtest', '[DEV]: Check styled log output', ->
  log('This is normal text')
  log('This is bold text', 'bold')
  log('This is italic text', 'italic')

  log('This is bold italic text', 'bold italic')

  log('Red', 'red')
  log('Green', 'green')
  log('Blue', 'blue')

  log('Cyan', 'cyan')
  log('Magenta', 'magenta')
  log('Yellow', 'yellow')

  log('COLORFUL AWESOMENESS', 'magenta bold italic')

task 'versions', '[DEV]: Check package.json versions', ->
  pkg = require('./package')
  for item in ['dependencies', 'devDependencies', 'peerDependencies']
    checkNpmVersions(pkg[item]) if pkg[item]

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

task 'forever', '[DEV]: Fake PRODUCTION environment for testing', ->
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

task 'deploy:action', '[REMOTE]: Update current app state from the repo and restart the server', ->
  log('Pulling updates from the repo')

  envParams['NODE_ENV'] = 'production'

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
