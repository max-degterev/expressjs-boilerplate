_ = require('lodash')
gulp = require('gulp')
livereload = require('gulp-livereload')

config = require('config')
utils = require('./utils')

process = (src, options) ->
  executor = (resolve, reject) ->
    startTime = Date.now()

    gulp
      .src(src)
      .pipe(require('gulp-stylus')(
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
      ))
      .on('error', utils.errorReporter)
      .pipe(require('gulp-rename')(options.name))
      .pipe(gulp.dest(options.dest))
      .pipe(livereload())
      .on('end', ->
        utils.benchmarkReporter("Stylusified #{utils.sourcesNormalize(src)}", startTime)
        resolve()
      )

  new Promise(executor)


module.exports = (options = {}) ->
  executor = (src, name) ->
    (resolve) ->
      settings = _.merge {}, options,
        name: name
        dest: "#{__dirname}/../#{config.build.assets_location}"

      resolve(process(src, settings))

  new Promise(executor("#{__dirname}/../styles/index.styl", 'app.css'))
