config = require('config')
createDomain = require('domain').create

_ = require('underscore')
app = require('express')()

env = require('env')
pkg = require('../../package')

getAsset = require('./lib/assets')
helpers = require('app/common/helpers')
log = require('app/common/logger')


#=====================================================================================
# Template globals
#=====================================================================================
generateTemplateGlobals = ->
  globals = {
    pretty: config.debug
    config: _.omit(_.clone(config), config.server_only_keys...)
    _
    helpers
    getAsset
  }

  _.extend(app.locals, globals)


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

generateEnv = (req, res, next)->
  requestEnv =
    rendered: (new Date).toUTCString()
    lang: require('../../config/lang/en_us')
    version: pkg.version

  _.extend(res.locals.env, requestEnv)

  next()

domainify = (req, res, next)->
  domain = createDomain()
  domain.add(req)
  domain.add(res)
  domain.run(next)
  domain.on('error', next)

preRouteMiddleware = ->
  app.use(domainify)
  app.use(require('morgan')(if config.debug then 'dev' else 'combined'))

  app.use(normalizeUrl)

  app.use(require('serve-favicon')(__dirname + '/../../public/favicon.ico'))
  app.use(require('serve-static')(__dirname + '/../../public', redirect: false))

  app.use(env.create)
  app.use(generateEnv)

postRouteMiddleware = ->
  app.use(require('errorhandler')(dumpExceptions: true, showStack: true)) if config.debug


#=====================================================================================
# Start listening
#=====================================================================================
module.exports.start = ->
  app.enable('trust proxy') # usually sitting behind nginx
  app.disable('x-powered-by')

  app.set('port', config.server.port)
  app.set('views', "#{__dirname}/../../templates")
  app.set('view engine', 'jade')
  app.set('json spaces', 2) if config.debug

  generateTemplateGlobals()

  preRouteMiddleware()
  require('./controllers').use(app)
  postRouteMiddleware()

  appRoot = "http://#{config.host or config.server.ip}:#{config.server.port}"
  serverMessage = "Server listening on #{appRoot}"

  if config.server.ip
    app.listen(config.server.port, config.server.ip, ->
      log("#{serverMessage} (bound to ip: #{config.server.ip})", 'cyan')
    )
  else
    app.listen(config.server.port, -> log("#{serverMessage} (unbound)", 'cyan'))
