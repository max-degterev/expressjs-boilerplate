gulp = require('gulp')

config = require('config')
utils = require('./utils')

source = "#{__dirname}/../client/index.coffee"

browserifyOptions =
  entries: source
  extensions: ['.coffee', '.cjsx', '.es', '.jsx']
  debug: config.debug

  cache: {}
  packageCache: {}
  fullPaths: true

cacheOptions =
  cacheFile: "#{__dirname}/.browserify-cache.json"


process = (options = {}) ->
  browserifyOptions.fullPaths = Boolean(options.watch)
  startTime = Date.now()

  bundler = require('browserify')(browserifyOptions)
  bundler = require('browserify-incremental')(bundler, cacheOptions) if options.watch

  bundler.transform(require('coffee-reactify'))
  bundler.transform(require('babelify').configure(extensions: ['.es', '.jsx']))

  bundler
    .bundle()
    .on('error', utils.errorReporter)

    .pipe(require('vinyl-source-stream')('app.js'))
    .pipe(gulp.dest("#{__dirname}/../#{config.build.assets_location}"))

    .on('end', ->
      utils.benchmarkReporter("Browserified #{utils.sourcesNormalize(source)}", startTime)
    )

module.exports = process
