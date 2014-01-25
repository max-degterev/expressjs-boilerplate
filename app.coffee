#=========================================================================================
# DEPENDENCIES & CONSTANTS
#=========================================================================================
helpers = require('./app/shared/helpers')
log = helpers.log

cluster = require('cluster')
config = require('config')
express = require('express')


#=========================================================================================
# FORKING
#=========================================================================================
if cluster.isMaster
  for i in [1..config.workers]
    log("Starting worker #{i}")
    cluster.fork()

  cluster.on 'exit', (worker, code, signal) ->
    log("Worker #{worker.process.pid} died")

    if config.debug
      process.exit()
    else
      cluster.fork()
else


#=========================================================================================
# INIT DB CONNECTION AND INSTANTIATE SERVER
#=========================================================================================
  server = require('./app/server')
  assetsHashMap = require('./public/assets/hashmap.json') unless config.debug

  app = express()


#=========================================================================================
# TEMPLATE GLOBABS
#=========================================================================================
  generateTemplateGlobals = ->
    app.locals.pretty = config.debug
    app.locals.helpers = helpers
    app.locals.env = process.env.NODE_ENV

    env = {}
    env[key] = config[key] for key in ['hostname', 'base_url', 'debug', 'ga_id']
    env.version = require('./package').version

    app.locals.client_env = env


#=========================================================================================
# MIDDLEWARE
#=========================================================================================
  _getAsset = (name)->
    if config.debug
      "/assets/#{name}"
    else
      ext = name.split('.').pop()
      baseName = name.replace('.' + ext, '')
      hash = assetsHashMap[name]
      "/assets/#{baseName}.min.#{hash}.#{ext}"

  gruntAssets = (req, res, next)->
    req.app.locals.getAsset = _getAsset
    next()

  setupMiddleware = ->
    app.use(express.static(__dirname + '/public'))
    # app.use(express.bodyParser())

    app.use(gruntAssets)

    unless config.debug
      app.use(express.compress())
      app.use(express.logger('default'))
    else
      app.use(express.errorHandler(dumpExceptions: true, showStack: true))
      app.use(express.logger('dev'))


#=========================================================================================
# START LISTENING FOR CONNECTIONS
#=========================================================================================
  app.enable('trust proxy') # usually sitting behind nginx
  app.disable('x-powered-by')

  app.set('port', config.port)
  app.set('views', __dirname + '/views/server')
  app.set('view engine', 'jade')

  generateTemplateGlobals()
  setupMiddleware()

  # Fire up the server
  app.use(app.router)
  server.use(app)

  if config.debug
    app.listen(app.get('port'), -> log("Server listening on http://#{config.hostname}:#{app.get('port')} (unbound)"))
  else
    if config.ip
      app.listen(app.get('port'), config.ip, -> log("Server listening on http://#{config.hostname}:#{app.get('port')} (bound to ip: #{config.ip})"))
    else
      app.listen(app.get('port'), -> log("Server listening on http://#{config.hostname}:#{app.get('port')} (unbound)"))
