#=========================================================================================
# Dependencies
#=========================================================================================
pkg = require('./package')
config = require('config')
_ = require('underscore')
fs = require('fs')

gulp = require('gulp')
del = require('del')

browserify = require('browserify')
watchify = require('watchify')
source = require('vinyl-source-stream')

stylus = require('gulp-stylus')
rename = require('gulp-rename')
nib = require('nib')

jade = require('gulp-jade')

uglify = require('gulp-uglify')
minifyCSS = require('gulp-minify-css')
htmlmin = require('gulp-htmlmin')

rev = require('gulp-rev')
gzip = require('gulp-gzip')

livereload = require('gulp-livereload') if config.livereload

log = require('app/common/logger').bind(logPrefix: '[gulp]')

bundler = null # for watchify to avoid memory leaks
lastBrowserified = 0

isBuild = process.argv[2] is 'build'
config.debug = false if isBuild


#=========================================================================================
# Settings
#=========================================================================================
RELOAD_TRIGGERS = ['rs', 'regulp']

PUBLIC_LOCATION = './public'
ASSETS_LOCATION = "#{PUBLIC_LOCATION}/assets"

JS_TRANSFORMS = ['coffeeify', 'jadeify']
MINIFIED_NAME = suffix: '.min'

BROWSERIFY_RATELIMIT = 1000


#=========================================================================================
# Reporters
#=========================================================================================
pathNormalize = (path)-> path.replace("#{__dirname}/", '').replace(/^\.\//, '')

benchmarkReporter = (action, startTime)->
  log("#{action} in #{((Date.now() - startTime) / 1000).toFixed(2)}s", 'magenta')

watchReporter = (e)->
  livereload.changed() if config.livereload
  log("File #{pathNormalize(e.path)} #{e.type}, flexing 💪", 'cyan')

errorReporter = (e)->
  stack = e.stack or e
  log("Browserify error!\n#{stack}", 'red bold')

getTemplateVars = ->
  helpers = require('app/common/helpers')
  {getAsset} = require('app/server/lib/assets')

  env =
    rendered: (new Date).toUTCString()
    lang: require('./config/lang/en_us')
    version: pkg.version

  {
    pretty: config.debug
    config: _.omit(_.clone(config), config.server_only_keys...)
    _
    helpers
    getAsset
    env
  }


#=========================================================================================
# Compilers
#=========================================================================================
compileJavascripts = (src, options)->
  opts =
    entries: src
    extensions: ['.coffee', '.jade']
    debug: config.source_maps
    cache: {}
    packageCache: {}
    fullPaths: true

  bundler.close?() if bundler
  bundler = browserify(opts)
  bundler = watchify(bundler) if options.watch

  bundler.transform(require(transform), global: true) for transform in JS_TRANSFORMS

  compile = (files)->
    startTime = Date.now()

    return if startTime - lastBrowserified < BROWSERIFY_RATELIMIT
    lastBrowserified = startTime

    watchReporter(path: file, type: 'changed') for file in files if files

    bundler.bundle()
      .on('error', errorReporter)
      .pipe(source(options.name))
      .pipe(gulp.dest(options.dest))
      .on('end', -> benchmarkReporter("Browserified #{src}", startTime))

  # bundler.on('file', (file)-> log("Browserifying #{pathNormalize(file)}", 'cyan'))
  bundler.on('update', compile) if options.watch
  compile()

compileStylesheets = (src, options)->
  startTime = Date.now()

  gulp.src(src)
    .pipe(stylus(
      errors: true
      # sourcemaps: config.source_maps
      use: [nib()]
      paths: ["#{__dirname}/node_modules"]
      'include css': true
      urlfunc: 'embedurl'
      linenos: true
      define:
        '$version': pkg.version
    ))
    .pipe(rename(options.name))
    .pipe(gulp.dest(options.dest))
    .on('end', -> benchmarkReporter("Stylusified #{src}", startTime))

compileTemplates = (src, options)->
  startTime = Date.now()

  gulp.src(src)
    .pipe(jade(
      pretty: true
      compileDebug: false
      locals: getTemplateVars()
    ))
    .pipe(gulp.dest(options.dest))
    .on('end', -> benchmarkReporter("Jadeified #{src}", startTime))

processOldAssets = (cb)->
  paths = ["#{ASSETS_LOCATION}/*.min-*"]
  lastBuildAssets = []

  try
    hashmap = fs.readFileSync("#{ASSETS_LOCATION}/hashmap.json", encoding: 'utf8')
    hashmap = JSON.parse(hashmap)
    lastBuildAssets = _.values(hashmap)

  for file in lastBuildAssets
    paths.push("!#{ASSETS_LOCATION}/#{file}")
    paths.push("!#{ASSETS_LOCATION}/#{file}.gz")

  del(paths, cb)

processJavascripts = (options = {})->
  settings = _.extend {}, options,
    name: 'app.js'
    dest: ASSETS_LOCATION

  compileJavascripts("./app/client/index.coffee", settings)

processStylesheets = (options = {})->
  settings = _.extend {}, options,
    name: 'app.css'
    dest: ASSETS_LOCATION

  compileStylesheets("./stylesheets/index.styl", settings)

processStaticStylesheets = ->
  compileStylesheets "#{__dirname}/stylesheets/static.styl",
    name: 'static.css'
    dest: ASSETS_LOCATION

processStaticTemplates = ->
  compileTemplates ["#{__dirname}/templates/static/**/*.jade", "!#{__dirname}/templates/static/**/_*.jade"],
    dest: ASSETS_LOCATION

gulp.task 'clean', (cb)-> processOldAssets(cb)
gulp.task 'browserify', -> processJavascripts()
gulp.task 'stylus', -> processStylesheets()
gulp.task 'static:stylus', -> processStaticStylesheets()
gulp.task 'static:jade', -> processStaticTemplates()

gulp.task 'minify', ['browserify', 'stylus', 'static:stylus'], ->
  gulp.src(["#{ASSETS_LOCATION}/*.js", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(uglify())
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

  gulp.src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(minifyCSS(
      processImport: false
      keepSpecialComments: 0
      aggressiveMerging: false
    ))
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'hashify', ['minify'], ->
  gulp.src(["#{ASSETS_LOCATION}/*.min.*", "#{ASSETS_LOCATION}/static.min.css"]) # can't find more than 2 files for some reason
    .pipe(rev())
    .pipe(gulp.dest("#{ASSETS_LOCATION}/"))
    .pipe(rev.manifest())
    .pipe(rename('hashmap.json'))
    .pipe(gulp.dest("#{ASSETS_LOCATION}/"))

gulp.task 'static', ['hashify'], ->
  processStaticTemplates()

gulp.task 'compress', ['static'], ->
  gulp.src(["#{ASSETS_LOCATION}/*.min-*.*", "!#{ASSETS_LOCATION}/*.gz"])
    .pipe(gzip())
    .pipe(gulp.dest(ASSETS_LOCATION))

  gulp.src("#{ASSETS_LOCATION}/*.html")
    .pipe(htmlmin(
      removeComments: true
      collapseWhitespace: true
      collapseBooleanAttributes: true
      removeAttributeQuotes: true
      removeRedundantAttributes: true
      useShortDoctype: true
      removeEmptyAttributes: true
    ))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'watch', ->
  livereload.listen(silent: true) if config.livereload

  processJavascripts(watch: true)
  processStylesheets()
  processStaticStylesheets()
  processStaticTemplates()

  # FIXME: This reload method is really slow
  templates = [
    "#{__dirname}/templates/**/*.jade"
    "!#{__dirname}/templates/static/**/*.jade"
  ]
  gulp.watch(templates).on 'change', (event)->
    watchReporter(event)
    processJavascripts(watch: true)

  stylesheets = [
    "#{__dirname}/stylesheets/**/*.styl"
    './vendor/**/*.css'
    './vendor/**/*.styl'
    "!#{__dirname}/stylesheets/static.styl"
  ]
  gulp.watch(stylesheets).on 'change', (event)->
    watchReporter(event)
    processStylesheets()

  staticContent = [
    "#{__dirname}/stylesheets/static.styl"
    "#{__dirname}/templates/static/**/*.jade"
  ]
  gulp.watch(staticContent).on 'change', (event)->
    watchReporter(event)
    processStaticStylesheets()
    processStaticTemplates()

  process.stdin.on 'data', (chunk)->
    if chunk.toString().replace(/[\r\n]/g, '') in RELOAD_TRIGGERS
      log('Triggered manual reload', 'red')
      processJavascripts(watch: true)
      processStylesheets()
      processStaticStylesheets()
      processStaticTemplates()

gulp.task('default', ['browserify', 'stylus', 'static:stylus', 'static:jade'])
gulp.task('build', ['compress'])
