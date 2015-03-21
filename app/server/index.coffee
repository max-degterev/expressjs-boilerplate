config = require('config')
createDomain = require('domain').create

_ = require('underscore')
app = require('express')()

env = require('env')
pkg = require('../../package')

helpers = require('../common/helpers')
log = helpers.log


generateAssetsMap = ->
  hash = {}
  for key, value of require('../../public/assets/hashmap.json')
    hash[key.replace('.min', '')] = value

  hash

assetsHashMap = generateAssetsMap() unless config.debug

#=====================================================================================
# Template globals
#=====================================================================================
getAsset = (name)->
  name = assetsHashMap[name] unless config.debug
  "/assets/#{name}"

generateTemplateGlobals = ->
  app.locals.pretty = config.debug
  app.locals.config = _.omit(_.clone(config), config.server_only_keys...)
  app.locals._ = _
  app.locals.helpers = helpers
  app.locals.getAsset = getAsset


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
  res.locals.env.rendered = (new Date).toUTCString()
  res.locals.env.lang = require('../../config/lang_en_us')
  res.locals.env.version = pkg.version

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
app.enable('trust proxy') # usually sitting behind nginx
app.disable('x-powered-by')

app.set('port', config.port)
app.set('views', "#{__dirname}/../../templates")
app.set('view engine', 'jade')
app.set('json spaces', 2) if config.debug

generateTemplateGlobals()

preRouteMiddleware()
require('./controllers').use(app)
postRouteMiddleware()

app_root = "http://#{config.hostname}:#{config.port}"

module.exports.start = ->
  if config.ip
    app.listen app.get('port'), config.ip, ->
      log("Server listening on #{app_root} (bound to ip: #{config.ip})", 'cyan')

  else
    app.listen app.get('port'), ->
      log("Server listening on #{app_root} (unbound)", 'cyan')

