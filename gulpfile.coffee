#=========================================================================================
# Dependencies
#=========================================================================================
pkg = require('./package')
config = require('config')
_ = require('underscore')

gulp = require('gulp')
clean = require('gulp-clean')

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

livereload = require('gulp-livereload')
server = null

helpers = require('app/javascripts/shared/helpers')
log = _.bind(helpers.log, logPrefix: '[gulp]')


#=========================================================================================
# Settings
#=========================================================================================
ASSETS_LOCATION = './public/assets'
PUBLIC_LOCATION = './public'
CORE_LOCATION = './app'

JS_TRANSFORMS = ['coffeeify', 'jadeify', 'browserify-shim']
MINIFIED_NAME = suffix: '.min'


#=========================================================================================
# Reporters
#=========================================================================================
pathNormalize = (path)-> path.replace("#{__dirname}/", '').replace(/^\.\//, '')

benchmarkReporter = (action, startTime)->
  log("#{action} in #{((Date.now() - startTime) / 1000).toFixed(2)}s", 'magenta')

watchReporter = (e)->
  server.changed(e.path) if server
  log("File #{pathNormalize(e.path)} #{e.type}, flexing 💪", 'cyan')

errorReporter = (e)->
  stack = e.stack or e
  log("Browserify error!\n#{stack}", 'red bold')


#=========================================================================================
# Compilers
#=========================================================================================
compileJavascripts = (src, options)->
  args = [src, extensions: ['.coffee', '.jade']]
  bundler = if options.watch then watchify(args...) else browserify(args...)

  bundler.require(key) for key of pkg['browserify-shim']
  bundler.transform(transform) for transform in JS_TRANSFORMS

  compile = (files)->
    startTime = Date.now()
    watchReporter(path: file, type: 'changed') for file in files if files

    bundler.bundle(debug: config.source_maps)
      .on('error', errorReporter)
      .pipe(source(options.name))
      .pipe(gulp.dest(options.dest))
      .on('end', -> benchmarkReporter('Browserified', startTime))

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
    .on('end', -> benchmarkReporter('Stylusified', startTime))

compileTemplates = (src, options)->
  startTime = Date.now()
  env = {}

  gulp.src(src)
    .pipe(jade(
      pretty: true
      compileDebug: false
      locals: { config, env, _, helpers }
    ))
    .pipe(gulp.dest(options.dest))
    .on('end', -> benchmarkReporter('Jadeified', startTime))

processJavascripts = (options = {})->
  settings = _.extend {}, options,
    name: 'app.js'
    dest: ASSETS_LOCATION

  compileJavascripts("#{CORE_LOCATION}/javascripts/client/index.coffee", settings)

processStylesheets = (options = {})->
  settings = _.extend {}, options,
    name: 'app.css'
    dest: ASSETS_LOCATION

  compileStylesheets("#{CORE_LOCATION}/stylesheets/index.styl", settings)

processStatic = ->
  compileStylesheets "#{CORE_LOCATION}/stylesheets/static.styl",
    name: 'static.css'
    dest: PUBLIC_LOCATION

  compileTemplates ["#{CORE_LOCATION}/templates/static/**/*.jade", "!#{CORE_LOCATION}/templates/static/**/_*.jade"],
    dest: PUBLIC_LOCATION

gulp.task 'clean', -> gulp.src(ASSETS_LOCATION, read: false).pipe(clean())
gulp.task 'browserify', -> processJavascripts()
gulp.task 'stylus', -> processStylesheets()
gulp.task 'static', -> processStatic()

gulp.task 'minify', ['browserify', 'stylus'], ->
  gulp.src("#{ASSETS_LOCATION}/*.js")
    .pipe(uglify())
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

  gulp.src("#{ASSETS_LOCATION}/*.css")
    .pipe(minifyCSS())
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

  gulp.src("#{PUBLIC_LOCATION}/static.css")
    .pipe(minifyCSS())
    .pipe(gulp.dest(PUBLIC_LOCATION))

  gulp.src("#{PUBLIC_LOCATION}/*.html")
    .pipe(htmlmin(
      removeComments: true
      collapseWhitespace: true
      collapseBooleanAttributes: true
      removeAttributeQuotes: true
      removeRedundantAttributes: true
      useShortDoctype: true
      removeEmptyAttributes: true
    ))
    .pipe(gulp.dest(PUBLIC_LOCATION))

gulp.task 'hashify', ['minify'], ->
  gulp.src("#{ASSETS_LOCATION}/*.min.*")
    .pipe(rev())
    .pipe(gulp.dest("#{ASSETS_LOCATION}/"))
    .pipe(rev.manifest())
    .pipe(rename('hashmap.json'))
    .pipe(gulp.dest("#{ASSETS_LOCATION}/"))

gulp.task 'compress', ['hashify'], ->
  gulp.src("#{ASSETS_LOCATION}/*.min-*.*")
    .pipe(gzip())
    .pipe(gulp.dest(ASSETS_LOCATION))

  gulp.src("#{PUBLIC_LOCATION}/*.css")
    .pipe(gzip())
    .pipe(gulp.dest(PUBLIC_LOCATION))

gulp.task 'watch', ->
  server = livereload() if config.livereload

  processJavascripts(watch: true)
  processStylesheets()

  stylesheets = [
    "#{CORE_LOCATION}/stylesheets/**/*.styl"
    './vendor/**/*.css'
    './vendor/**/*.styl'
    "!#{CORE_LOCATION}/stylesheets/static.styl"
  ]
  gulp.watch(stylesheets).on 'change', (event)->
    watchReporter(event)
    processStylesheets()

  staticContent = [
    "#{CORE_LOCATION}/stylesheets/static.styl"
    "#{CORE_LOCATION}/templates/static/**/*.jade"
  ]
  gulp.watch(staticContent).on 'change', (event)->
    watchReporter(event)
    processStatic()

gulp.task('default', ['browserify', 'stylus', 'static'])
gulp.task('build', ['compress'])
