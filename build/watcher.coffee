{ resolve } = require('path')
gulp = require('gulp')

config = require('config')
utils = require('./utils')

nodemonOptions =
  script: 'app.js'
  ext: 'js json coffee cjsx es jsx'
  watch: [
    'config/*'
    'server/*'
    'app.js'
  ]

nodemonOptions.watch.push('client/*') if config.server.prerender

SERVER_PATH = resolve("#{__dirname}/../app.js")
SERVER_RESTART_TIME = 1000 # can dick around checking if port is up, but fuck it


watcher = ->
  livereload = require('gulp-livereload')
  eslint = require('gulp-eslint')
  compileScripts = require('./scripts')
  compileStyles = require('./styles')

  nodemonRestarts = 0

  # relative paths required for watch/Gaze to detect changes in new files
  scripts = [
    'client/**/*.coffee'
    'vendor/**/*.coffee'
    'client/**/*.es'
    'vendor/**/*.es'
  ]

  stylesheets = [
    'client/**/*.styl'
    'styles/**/*.styl'
    'vendor/**/*.css'
  ]

  templates = [
    'templates/**/*.pug'
  ]

  lintableScripts = [
    'build/**/*.es'
    'client/**/*.es'
    'config/**/*.es'
    'server/**/*.es'
    '*.es'
    '*.js'
  ]

  lintableStyles = [
    'client/**/*.styl'
    'styles/**/*.styl'
  ]

  reloadPage = -> livereload.reload(SERVER_PATH)

  lintScripts = ->
    gulp.src(lintableScripts)
      .pipe(eslint())
      .pipe(eslint.format('codeframe'))

  lintStyles = ->
    commands = for path in lintableStyles
      "stylint ./#{path.replace('**/*.styl', '')} --color"

    utils.proxy(commands.join(';'))

  livereload.listen()
  nodemon = require('gulp-nodemon')(nodemonOptions)

  gulp.watch(scripts).on('change', (event) ->
    utils.watchReporter(event)
    stream = compileScripts(watch: true)
    stream = stream.pipe(livereload()) unless config.server.prerender
    stream
  )

  gulp.watch(stylesheets).on('change', (event) ->
    utils.watchReporter(event)
    compileStyles().pipe(livereload())
  )

  gulp.watch(templates).on('change', (event) ->
    utils.watchReporter(event)
    reloadPage()
  )

  gulp.watch(lintableScripts).on('change', (event) ->
    lintScripts()
  )

  gulp.watch(lintableStyles).on('change', (event) ->
    lintStyles()
  )

  nodemon.on('start', ->
    setTimeout(reloadPage, SERVER_RESTART_TIME) if nodemonRestarts
    nodemonRestarts++
  )

  nodemon.on('restart', (files) ->
    event = type: 'change'

    for path in files
      event.path = path
      utils.watchReporter(event)
  )

  lintScripts()
  lintStyles()

module.exports = watcher
