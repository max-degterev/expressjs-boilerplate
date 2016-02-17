_ = require('lodash')
gulp = require('gulp')
livereload = require('gulp-livereload')

config = require('config')
utils = require('./utils')

process = (src, options) ->
  executor = (resolve, reject) ->
    opts =
      entries: src
      extensions: ['.coffee', '.cjsx']
      debug: config.debug
      cache: {}
      packageCache: {}
      fullPaths: config.debug

    bundler = require('browserify')(opts)
    bundler = require('watchify')(bundler) if options.watch

    bundler.transform(require('coffee-reactify'))

    compile = (files) ->
      startTime = Date.now()

      utils.watchReporter(path: file, type: 'changed') for file in files if files

      bundler
        .bundle()
        .on('error', utils.errorReporter)
        .pipe(require('vinyl-source-stream')(options.name))
        .pipe(gulp.dest(options.dest))
        .pipe(livereload())
        .on('end', ->
          utils.benchmarkReporter("Browserified #{utils.sourcesNormalize(src)}", startTime)
          resolve()
        )

    # bundler.on('file', (file) -> console.log(chalk.cyan("Browserifying #{pathNormalize(file)}")))
    bundler.on('update', compile) if options.watch
    compile()

  new Promise(executor)

module.exports = (options = {}) ->
  executor = (src, name, cssName) ->
    (resolve) ->
      settings = _.assignIn {}, options,
        name: name
        dest: "#{__dirname}/../#{config.build.assets_location}"

      resolve(process(src, settings))

  new Promise(executor("#{__dirname}/../client/index.coffee", 'app.js'))
