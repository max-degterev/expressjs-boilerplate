pkg = require('./package')

gulp = require('gulp')
util = require('gulp-util')
plumber = require('gulp-plumber')

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

watchReporter = (e)->
  util.log("File #{util.colors.cyan(e.path)} was #{util.colors.red(e.type)}, compiling 💪")

compileJavascripts = (src, options)->
  args = [src, extensions: ['.coffee', '.jade']]
  bundler = if options.watch then watchify(args...) else browserify(args...)

  compile = ->
    bundler.bundle()
      .pipe(plumber(util.log))
      .pipe(source(options.name))
      .pipe(gulp.dest(options.dest))

  bundler.on('update', compile) if options.watch
  compile()

compileStylesheets = (src, options)->
  gulp.src(src)
    .pipe(plumber(util.log))
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
    .pipe(plumber(util.log))
    .pipe(jade(
      pretty: true
      compileDebug: false
    ))
    .pipe(gulp.dest(options.dest))



gulp.task 'clean', ->
  gulp.src('./public/assets', read: false)
    .pipe(clean())

gulp.task 'browserify', ->
  compileJavascripts './app/javascripts/client/index.coffee',
    name: 'app.js'
    dest: './public/assets'

gulp.task 'stylus', ->
  compileStylesheets './app/stylesheets/index.styl',
    name: 'app.css'
    dest: './public/assets'

gulp.task 'static', ->
  compileStylesheets './app/stylesheets/static.styl',
    name: 'static.css'
    dest: './public'

  compileTemplates ['./app/templates/static/**/*.jade', '!./app/templates/static/**/_*.jade'],
    dest: './public'

gulp.task 'minify', ->
  gulp.src('./public/assets/*.js')
    .pipe(uglify())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest('./public/assets'))

  gulp.src('./public/assets/*.css')
    .pipe(minifyCSS())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest('./public/assets'))

  gulp.src('./public/static.css')
    .pipe(minifyCSS())
    .pipe(gulp.dest('./public'))

  gulp.src('./public/*.html')
    .pipe(htmlmin(
      removeComments: true
      collapseWhitespace: true
      collapseBooleanAttributes: true
      removeAttributeQuotes: true
      removeRedundantAttributes: true
      useShortDoctype: true
      removeEmptyAttributes: true
    ))
    .pipe(gulp.dest('./public'))

gulp.task 'hashify', ->
  gulp.src('./public/assets/*.min.*')
    .pipe(rev())
    .pipe(gulp.dest('./public/assets/'))
    .pipe(rev.manifest())
    .pipe(rename('hashmap.json'))
    .pipe(gulp.dest('./public/assets/'))

gulp.task 'compress', ->
  gulp.src('./public/assets/*.min-*.*')
    .pipe(gzip())
    .pipe(gulp.dest('./public/assets'))

  gulp.src('./public/*.css')
    .pipe(gzip())
    .pipe(gulp.dest('./public'))

gulp.task 'watch', ->
  compileJavascripts './app/javascripts/client/index.coffee',
    name: 'app.js'
    dest: './public/assets'
    watch: true

  javascripts = [
    './app/javascripts/client/**/*.coffee'
    './app/javascripts/shared/**/*.coffee'
    './vendor/**/*.js'
    './vendor/**/*.coffee'
    './app/templates/client/**/*.jade'
    './app/templates/shared/**/*.jade'
  ]
  gulp.watch(javascripts).on('change', watchReporter)

  stylesheets = [
    './app/stylesheets/**/*.styl'
    './vendor/**/*.css'
    './vendor/**/*.styl'
    '!./app/stylesheets/static.styl'
  ]
  gulp.watch(stylesheets, ['stylus']).on('change', watchReporter)

  templates = [
    './app/stylesheets/static.styl'
    './app/templates/static/**/*.jade'
  ]
  gulp.watch(templates, ['static']).on('change', watchReporter)


gulp.task 'default', ['browserify', 'stylus']
gulp.task 'build', ['default']

