pkg = require('./package')

gulp = require('gulp')
source = require('vinyl-source-stream')
rename = require('gulp-rename')

browserify = require('browserify')
stylus = require('gulp-stylus')
nib = require('nib')

gulp.task 'browserify', ->
  browserify('./app/javascripts/client/index.coffee', extensions: ['.coffee'])
    .bundle()
    .pipe(source('app.js'))
    .pipe(gulp.dest('./public/assets'))

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

gulp.task 'default', ['browserify', 'stylus'], ->
gulp.task 'build', ['default'], ->
gulp.task 'watch', ['default'], ->
