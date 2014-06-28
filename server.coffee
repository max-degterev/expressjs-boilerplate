#=========================================================================================
# Application setup
#=========================================================================================
config = require('config')
cluster = require('cluster')
_ = require('underscore')
app = require('express')()

env = require('env')
helpers = require('app/javascripts/shared/helpers')
log = helpers.log


#=========================================================================================
# Forking
#=========================================================================================
if cluster.isMaster
  for i in [1..config.workers]
    log("Starting worker #{i}")
    cluster.fork()

  cluster.on 'exit', (worker, code, signal)->
    log("Worker #{worker.process.pid} died")

    if config.debug
      process.exit()
    else
      cluster.fork()

else


  #=======================================================================================
  # Instantiate server
  #=======================================================================================
  domain = require('domain').create()
  domain.on 'error', (err)->
    log(err.stack || err, 'red')

    killtimer = setTimeout ->
      process.exit(1)
    , config.death_timeout
    killtimer.unref()

  domain.run ->
    server = require('./app/javascripts/server')
    unless config.debug
      assetsHashMap = {}
      for key, value of require('./public/assets/hashmap.json')
        assetsHashMap[key.replace('.min', '')] = value


    #=====================================================================================
    # Template globals
    #=====================================================================================
    generateTemplateGlobals = ->
      app.locals.pretty = config.debug
      app.locals.config = _.omit(_.clone(config), 'server_only_keys', config.server_only_keys...)
      app.locals._ = _
      app.locals.helpers = helpers


    #=====================================================================================
    # Global middleware
    #=====================================================================================
    normalizeUrl = (req, res, next)->
      try
        decodeURIComponent(req.originalUrl)
      catch
        url = '/'
        log("malformed URL, redirecting to #{url}")
        return res.redirect(301, url)

      [href, qs...] = req.originalUrl.split('?')

      if qs.length > 1 # should be 1?2, [2].length = 1
        url = href + '?' + qs.join('&')
        log("malformed URL, redirecting to #{url}")
        return res.redirect(301, url)

      next()

    getAsset = (name)->
      name = assetsHashMap[name] unless config.debug
      "/assets/#{name}"

    injectGetAsset = (req, res, next)->
      req.app.locals.getAsset = getAsset
      next()

    generateEnv = (req, res, next)->
      rendered = (new Date).toUTCString()
      lang = require('./config/lang_en_us')

      env.restore(res).set({ rendered, lang })
      next()

    preRouteMiddleware = ->
      morgan = require('morgan')

      if config.debug
        app.use(morgan('dev'))
      else
        app.use(morgan('default'))

      app.use(normalizeUrl)

      app.use(require('serve-favicon')(__dirname + '/public/favicon.ico'))
      app.use(require('serve-static')(__dirname + '/public', redirect: false))

      app.use(injectGetAsset)
      app.use(env.create)
      app.use(generateEnv)

    postRouteMiddleware = ->
      if config.debug
        app.use(require('errorhandler')(dumpExceptions: true, showStack: true))
      else
        app.use(require('compression')())


    #=====================================================================================
    # Start listening
    #=====================================================================================
    app.enable('trust proxy') # usually sitting behind nginx
    app.disable('x-powered-by')

    app.set('port', config.port)
    app.set('views', "#{__dirname}/app/templates")
    app.set('view engine', 'jade')
    app.set('json spaces', 2) if config.debug

    generateTemplateGlobals()

    preRouteMiddleware()
    server.use(app) # Fire up the server, all the routes go here
    postRouteMiddleware()

    app_root = "http://#{config.hostname}:#{config.port}"

    if config.debug
      app.listen(app.get('port'), -> log("Server listening on #{app_root} (unbound)", 'cyan'))
    else
      if config.ip
        app.listen(app.get('port'), config.ip, -> log("Server listening on #{app_root} (bound to ip: #{config.ip})", 'cyan'))
      else
        app.listen(app.get('port'), -> log("Server listening on #{app_root} (unbound)", 'cyan'))
