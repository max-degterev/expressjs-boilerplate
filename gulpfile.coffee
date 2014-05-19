pkg = require('./package')

gulp = require('gulp')

browserify = require('browserify')
watchify = require('watchify')
source = require('vinyl-source-stream')

stylus = require('gulp-stylus')
rename = require('gulp-rename')
nib = require('nib')

jade = require('gulp-jade')
commonjs = require('gulp-commonjs-jade')
concat = require('gulp-concat')

watch = false

gulp.task 'browserify', ->
  options = ['./app/javascripts/client/index.coffee', extensions: ['.coffee']]
  bundler = if watch then watchify(options...) else browserify(options...)

  compile = ->
    bundler.bundle()
      .pipe(source('app.js'))
      .pipe(gulp.dest('./public/assets'))

  bundler.on('update', compile)
  compile()

gulp.task 'stylus', ->
  gulp.src('./app/stylesheets/index.styl')
    .pipe(stylus(
      errors: true
      use: [nib()]
      'include css': true
      urlfunc: 'embedurl'
      linenos: true
      define:
        '$version': pkg.version
    ))
    .pipe(rename('app.css'))
    .pipe(gulp.dest('./public/assets'))

gulp.task 'jade', ->
  gulp.src('./app/templates/client/**/*.jade')
    .pipe(jade(
      pretty: true
      compileDebug: false
      client: true
    ))
    .pipe(commonjs(
      processName: (file)-> file.replace(/^.*app\/templates\/client\/([\w\/]+).js$/gi, '$1')
    ))
    .pipe(concat('jst.js'))
    .pipe(gulp.dest('./.tmp'))

gulp.task 'default', ['browserify', 'stylus'], ->
gulp.task 'build', ['default'], ->
gulp.task 'watch', ['default'], ->
