_ = require('lodash')

gulp = require('gulp')
gulpSequence = require('gulp-sequence')

chalk = require('chalk')
rename = require('gulp-rename')
connect = require('gulp-connect')

config = require('./config')

# to have control over watchify instances
watchifyCompilers = []


#=========================================================================================
# Settings
#=========================================================================================
RELOAD_TRIGGERS = ['rs', 'regulp']

ASSETS_NAME = 'assets'

PUBLIC_LOCATION = './public'
ASSETS_LOCATION = "#{PUBLIC_LOCATION}/#{ASSETS_NAME}"

MINIFIED_NAME = suffix: '.min'


#=========================================================================================
# Reporters
#=========================================================================================
pathNormalize = (path) ->
  "./#{path.replace("#{__dirname}/", '')}"

sourcesNormalize = (paths) ->
  paths = [paths] if !_.isArray(paths)
  paths.map(pathNormalize)

benchmarkReporter = (action, startTime) ->
  console.log(chalk.magenta("#{action} in #{((Date.now() - startTime) / 1000).toFixed(2)}s"))

watchReporter = (e) ->
  console.log(chalk.cyan("File #{pathNormalize(e.path)} #{e.type}, flexing 💪"))

errorReporter = (e) ->
  stack = e.stack or e
  console.log(chalk.bold.red("Build error!\n#{stack}"))


#=========================================================================================
# Compilers
#=========================================================================================
compileJavascripts = (src, options) ->
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

      watchReporter(path: file, type: 'changed') for file in files if files

      bundler
        .bundle()
        .on('error', errorReporter)
        .pipe(require('vinyl-source-stream')(options.name))
        .pipe(gulp.dest(options.dest))
        .pipe(connect.reload())
        .on('end', ->
          benchmarkReporter("Browserified #{sourcesNormalize(src)}", startTime)
          resolve()
        )

    watchifyCompilers.push(compile)

    # bundler.on('file', (file) -> console.log(chalk.cyan("Browserifying #{pathNormalize(file)}")))
    bundler.on('update', compile) if options.watch
    compile()

  new Promise(executor)

compileStylesheets = (src, options) ->
  executor = (resolve, reject) ->
    startTime = Date.now()

    gulp
      .src(src)
      .pipe(require('gulp-stylus')(
        errors: config.debug
        sourcemaps: config.debug
        use: [ require('nib')() ]
        paths: [
          "#{__dirname}/client"
          "#{__dirname}/node_modules"
        ]
        'include css': true
        urlfunc: 'embedurl'
        linenos: config.debug
      ))
      .on('error', errorReporter)
      .pipe(rename(options.name))
      .pipe(gulp.dest(options.dest))
      .pipe(connect.reload())
      .on('end', ->
        benchmarkReporter("Stylusified #{sourcesNormalize(src)}", startTime)
        resolve()
      )

  new Promise(executor)

compileTemplates = (src, options) ->
  generateAssetsMap = ->
    hash = {}
    for key, value of require("#{ASSETS_LOCATION}/hashmap.json")
      hash[key.replace('.min', '')] = value

    hash

  executor = (resolve, reject) ->
    startTime = Date.now()

    assetsHashMap = generateAssetsMap() if config.debug

    injectAsset = (name) ->
      _orig = name

      name = assetsHashMap[name] if config.debug
      errorReporter("Templates compiler: \"#{_orig}\" asset not found!") unless name

      "/#{ASSETS_NAME}/#{name}"

    injectConfig = (key) ->
      if key
        clientConfig = _.merge(_.cloneDeep(config[key]), _.pick(config, 'debug', 'environment'))
      else
        clientConfig = _.cloneDeep(config)

      "<script>__$$config__ = #{sanitize(JSON.stringify(clientConfig))};</script>"

    gulp
      .src(src)
      .pipe(require('gulp-template')(
        asset: injectAsset,
        config: injectConfig
      ))
      .pipe(gulp.dest(options.dest))
      .pipe(connect.reload())
      .on('end', ->
        benchmarkReporter("Templatified #{sourcesNormalize(src)}", startTime)
        resolve()
      )

  new Promise(executor)


#=========================================================================================
# Processing shortcuts
#=========================================================================================
processJavascripts = (options = {}) ->
  executor = (src, name, cssName) ->
    (resolve) ->
      settings = _.assignIn {}, options,
        name: name
        dest: ASSETS_LOCATION

      resolve(compileJavascripts(src, settings))

  new Promise(executor("#{__dirname}/client/index.coffee", 'app.js'))

processStylesheets = (options = {}) ->
  executor = (src, name) ->
    (resolve) ->
      settings = _.assignIn {}, options,
        name: name
        dest: ASSETS_LOCATION

      resolve(compileStylesheets(src, settings))

  new Promise(executor("#{__dirname}/styles/index.styl", 'app.css'))

processTemplates = (options = {}) ->
  executor = (src, dest) ->
    (resolve) ->
      settings = _.assignIn {}, options,
        dest: dest

      resolve(compileTemplates(src, settings))

  new Promise(executor([
    "#{__dirname}/templates/*.html",
    "!#{__dirname}/templates/_*.html"
  ], PUBLIC_LOCATION))

startDevserver = ->
  connect.server(
    root: PUBLIC_LOCATION
    port: config.server.port
    host: config.server.host
    livereload: config.debug
    fallback: "#{PUBLIC_LOCATION}/index.html"
  )

reprocessJavascripts = -> compile() for compile in watchifyCompilers

#=========================================================================================
# Tasks definitions
#=========================================================================================
gulp.task 'scripts', -> processJavascripts()
gulp.task 'styles', -> processStylesheets()
gulp.task 'templates', -> processTemplates()

gulp.task 'serve', -> startDevserver()

gulp.task 'decache:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-css-decache')(
      base: PUBLIC_LOCATION
      logMissing: true
    ))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:scripts', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.js", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-uglify')(
      compress: { drop_console: true }
    ))
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(require('gulp-minify-css')(
      processImport: false
      keepSpecialComments: 0
      aggressiveMerging: false
    ))
    .pipe(rename(MINIFIED_NAME))
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
    .src(["#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.gz"])
    .pipe(require('gulp-gzip')())
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:templates', ->
  gulp
    .src("#{PUBLIC_LOCATION}/**/*.html")
    .pipe(require('gulp-htmlmin')(
      removeComments: true
      collapseWhitespace: true
      useShortDoctype: true
    ))
    .pipe(gulp.dest(PUBLIC_LOCATION))

gulp.task 'clean', (done) ->
  require('del')([
    ASSETS_LOCATION,
    "#{PUBLIC_LOCATION}/*.html"
  ], done)

gulp.task('build', gulpSequence(
  'clean',
  [
    'scripts'
    'styles'
  ],
  'decache:styles',
  [
    'minify:scripts'
    'minify:styles'
  ]
  'hashify',
  'templates',
  [
    'minify:templates'
    'compress'
  ]
))

gulp.task('compile',
  [
    'scripts'
    'styles'
    'templates'
  ]
)

gulp.task 'default', ->
  Promise.all([
    processJavascripts(watch: true),
    processStylesheets()
    processTemplates()
  ]).then ->
    startDevserver()

    stylesheets = [
      "#{__dirname}/**/*.styl"
      "#{__dirname}/vendor/**/*.css"
    ]
    gulp.watch(stylesheets).on 'change', (event) ->
      watchReporter(event)
      processStylesheets()

    templates = [
      "#{__dirname}/templates/**/*.html"
    ]
    gulp.watch(templates).on 'change', (event) ->
      watchReporter(event)
      processTemplates(watch: true)

    process.stdin.on 'data', (chunk) ->
      if chunk.toString().replace(/[\r\n]/g, '') in RELOAD_TRIGGERS
        console.log(chalk.red('Triggered manual reload'))
        reprocessJavascripts()
        processStylesheets()
        processTemplates()
