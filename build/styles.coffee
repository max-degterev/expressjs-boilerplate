gulp = require('gulp')

config = require('config')
utils = require('./utils')

source = "#{__dirname}/../styles/index.styl"

stylusOptions =
  errors: config.debug
  sourcemaps: config.debug
  use: [ require('nib')() ]
  paths: [
    "#{__dirname}/../client"
    "#{__dirname}/../node_modules"
  ]
  'include css': true
  urlfunc: 'embedurl'
  linenos: config.debug


process = ->
  startTime = Date.now()

  gulp
    .src(source)
    .pipe(require('gulp-stylus')(stylusOptions))
    .on('error', utils.errorReporter)

    .pipe(require('gulp-rename')('app.css'))
    .pipe(gulp.dest("#{__dirname}/../#{config.build.assets_location}"))

    .on('end', ->
      utils.benchmarkReporter("Stylusified #{utils.sourcesNormalize(source)}", startTime)
    )

module.exports = process
