pkg = require('./package')
_ = require('lodash')

gulp = require('gulp')
util = require('gulp-util')

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

ASSETS_LOCATION = './public/assets'
PUBLIC_LOCATION = './public'
CORE_LOCATION = './app'

watchReporter = (e)->
  util.log("File #{util.colors.cyan(e.path)} #{util.colors.red(e.type)}, flexing 💪")
errorReporter = (e)->
  stack = e.stack or e
  util.log("#{util.colors.magenta('Browserify error!')}\n#{util.colors.red(stack)}")

compileJavascripts = (src, options)->
  args = [src, extensions: ['.coffee', '.jade']]
  bundler = if options.watch then watchify(args...) else browserify(args...)

  compile = (files)->
    watchReporter(path: files[0], type: 'changed') if files
    bundler.bundle()
      .on('error', errorReporter)
      .pipe(source(options.name))
      .pipe(gulp.dest(options.dest))

  bundler.on('update', compile) if options.watch
  bundler.on('file', (file)-> util.log("Browserifying #{util.colors.cyan(file)}"))
  compile()

compileStylesheets = (src, options)->
  gulp.src(src)
    .pipe(stylus(
      errors: true
      use: [nib()]
      'include css': true
      urlfunc: 'embedurl'
      linenos: true
      define:
        '$version': pkg.version
    ))
    .pipe(rename(options.name))
    .pipe(gulp.dest(options.dest))

compileTemplates = (src, options)->
  gulp.src(src)
    .pipe(jade(
      pretty: true
      compileDebug: false
    ))
    .pipe(gulp.dest(options.dest))

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
gulp.task 'browserify', ['clean'], -> processJavascripts()
gulp.task 'stylus', ['clean'], -> processStylesheets()
gulp.task 'static', ['clean'], -> processStatic()

gulp.task 'minify', ['browserify', 'stylus'], ->
  gulp.src("#{ASSETS_LOCATION}/*.js")
    .pipe(uglify())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest(ASSETS_LOCATION))

  gulp.src("#{ASSETS_LOCATION}/*.css")
    .pipe(minifyCSS())
    .pipe(rename(suffix: '.min'))
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
  processJavascripts(watch: true)

  stylesheets = [
    "#{CORE_LOCATION}/stylesheets/**/*.styl"
    './vendor/**/*.css'
    './vendor/**/*.styl'
    "!#{CORE_LOCATION}/stylesheets/static.styl"
  ]
  gulp.watch(stylesheets).on 'change', (event)->
    watchReporter(event)
    processStylesheets()

  templates = [
    "#{CORE_LOCATION}/stylesheets/static.styl"
    "#{CORE_LOCATION}/templates/static/**/*.jade"
  ]
  gulp.watch(templates).on 'change', (event)->
    watchReporter(event)
    processStatic()

gulp.task('default', ['browserify', 'stylus', 'static'])
gulp.task('build', ['compress'])
