_ = require('lodash')

gulp = require('gulp')
gulpSequence = require('gulp-sequence')
rename = require('gulp-rename')

config = require('./config')
utils = require('./build/utils')

compileScripts = require('./build/scripts')
compileStyles = require('./build/styles')
#compileTemplates = require('./build/templates')

MINIFICATION_RULES = suffix: '.min'
ASSETS_LOCATION = "./#{config.assets_location}"
PUBLIC_LOCATION = "./public"


gulp.task 'scripts', -> compileScripts()
gulp.task 'styles', -> compileStyles()
# gulp.task 'templates', -> compileTemplates()

gulp.task 'decache:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-css-decache')(
      base: PUBLIC_LOCATION
      logMissing: true
    ))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:scripts', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.js", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-uglify')(
      compress: { drop_console: true }
    ))
    .pipe(rename(MINIFICATION_RULES))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-minify-css')(
      processImport: false
      keepSpecialComments: 0
      aggressiveMerging: false
    ))
    .pipe(rename(MINIFICATION_RULES))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'hashify', ->
  rev = require('gulp-rev')

  gulp
    .src("#{ASSETS_LOCATION}/*.min.*")
    .pipe(rev())
    .pipe(gulp.dest(ASSETS_LOCATION))
    .pipe(rev.manifest('hashmap.json'))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'compress', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.gz"])
    .pipe(require('gulp-gzip')())
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:templates', ->
  gulp
    .src("#{PUBLIC_LOCATION}/**/*.html")
    .pipe(require('gulp-htmlmin')(
      removeComments: true
      collapseWhitespace: true
      useShortDoctype: true
    ))
    .pipe(gulp.dest(PUBLIC_LOCATION))

gulp.task 'clean', (done) -> require('del')([ASSETS_LOCATION], done)

gulp.task('build', gulpSequence(
  'clean',
  ['scripts','styles'],
  'decache:styles',

  ['minify:scripts', 'minify:styles']
  'hashify',
  #'templates',

  ['minify:templates', 'compress']
))

gulp.task('compile',
  #'templates'
  ['scripts','styles']
)

gulp.task 'default', ->
  Promise.all([
    compileScripts(watch: true),
    compileStyles()
    #compileTemplates()
  ]).then ->
    stylesheets = [ "#{__dirname}/**/*.styl", "#{__dirname}/vendor/**/*.css" ]
    gulp.watch(stylesheets).on 'change', (event) ->
      utils.watchReporter(event)
      compileStyles()

    # templates = [ "#{__dirname}/templates/**/*.html" ]
    # gulp.watch(templates).on 'change', (event) ->
    #   utils.watchReporter(event)
    #   compileTemplates(watch: true)
