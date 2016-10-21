config = require('config')
gulp = require('gulp')

MINIFICATION_RULES = suffix: '.min'
ASSETS_LOCATION = "#{__dirname}/#{config.build.assets_location}"


gulp.task 'clean', (done) -> require('del')([ASSETS_LOCATION], done)

gulp.task 'scripts', -> require('./build/scripts')()
gulp.task 'styles', -> require('./build/styles')()

gulp.task 'decache:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-css-decache')(
      base: "#{__dirname}/public"
      logMissing: true
    ))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:scripts', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.js", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-uglify')(
      compress: { drop_console: true }
    ))
    .pipe(require('gulp-rename')(MINIFICATION_RULES))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-clean-css')(
      processImport: false
      keepSpecialComments: 0
      aggressiveMerging: false
    ))
    .pipe(require('gulp-rename')(MINIFICATION_RULES))
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
    .src(["#{ASSETS_LOCATION}/app-*.min.*", "!#{ASSETS_LOCATION}/*.gz"])
    .pipe(require('gulp-gzip')())
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task('build', require('gulp-sequence')(
  'clean'

  ['scripts', 'styles'],
  'decache:styles'

  ['minify:scripts', 'minify:styles']
  'hashify'

  'compress'
))

gulp.task('compile', ['scripts', 'styles'])

gulp.task 'default', ->
  actions = [
    require('./build/scripts')(watch: true)
    require('./build/styles')()
  ]

  Promise.all(actions).then(require('./build/watcher'))
