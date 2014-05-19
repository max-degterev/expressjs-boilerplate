pkg = require('./package')

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


compileJavascripts = (src, options)->
  args = [src, extensions: ['.coffee', '.jade']]
  bundler = if options.watch then watchify(args...) else browserify(args...)

  compile = ->
    bundler.bundle()
      .pipe(source(options.name))
      .pipe(gulp.dest(options.dest))

  bundler.on('update', compile)
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



gulp.task 'clean', ->
  gulp.src('./public/assets', read: false)
    .pipe(clean())

gulp.task 'browserify', ->
  compileJavascripts './app/javascripts/client/index.coffee',
    name: 'app.js'
    dest: './public/assets'
    watch: false

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

gulp.task 'compress', ->
  gulp.src('./public/assets/*.js')
    .pipe(uglify())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest('./public/assets'))

  gulp.src(['./public/assets/*.css'])
    .pipe(minifyCSS())
    .pipe(rename(suffix: '.min'))
    .pipe(gulp.dest('./public/assets'))

  gulp.src(['./public/static.css'])
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







gulp.task 'default', ['browserify', 'stylus']
gulp.task 'build', ['default']
gulp.task 'watch', ['default']
