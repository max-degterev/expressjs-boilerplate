_ = require('lodash')

gulp = require('gulp')
gulpSequence = require('gulp-sequence')

rename = require('gulp-rename')

config = require('config')

compileScripts = require('./build/scripts')
compileStyles = require('./build/styles')


MINIFICATION_RULES = suffix: '.min'
ASSETS_LOCATION = "#{__dirname}/#{config.build.assets_location}"


gulp.task 'clean', (done) -> require('del')([ASSETS_LOCATION], done)

gulp.task 'scripts', -> compileScripts()
gulp.task 'styles', -> compileStyles()

gulp.task 'decache:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-css-decache')(
      base: '#{__dirname}/public'
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

gulp.task('build', gulpSequence(
  'clean',

  ['scripts','styles'],
  'decache:styles',

  ['minify:scripts', 'minify:styles']
  'hashify',

  'compress'
))

gulp.task('compile', ['scripts','styles'])

gulp.task 'default', ->
  Promise.all([
    compileScripts(watch: true),
    compileStyles()
  ]).then ->
    require('gulp-livereload').listen()

    stylesheets = [ "#{__dirname}/styles/**/*.styl", "#{__dirname}/vendor/**/*.css" ]
    gulp.watch(stylesheets).on 'change', (event) ->
      require('./build/utils').watchReporter(event)
      compileStyles()
