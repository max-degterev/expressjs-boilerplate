#=========================================================================================
# Dependencies
#=========================================================================================

_ = require('lodash')

gulp = require('gulp')
chalk = require('chalk')

gulpSequence = require('gulp-sequence')

browserify = require('browserify')
watchify = require('watchify')

coffeeReactify = require('coffee-reactify')

source = require('vinyl-source-stream')
watchifyCompilers = [] # to have control over watchify instances

stylus = require('gulp-stylus')
rename = require('gulp-rename')
nib = require('nib')

template = require('gulp-template')

connect = require('gulp-connect')
open = require('open')

fs = require('fs-extra')
glob = require('glob')
unzip = require('unzip')

needle = require('needle')
fontello = require('./lib/fontello')

uglify = require('gulp-uglify')

decache = require('gulp-css-decache')
minifyCSS = require('gulp-minify-css')
htmlmin = require('gulp-htmlmin')

rev = require('gulp-rev')
gzip = require('gulp-gzip')
del = require('del')

sanitize = require('./lib/sanitize')

isBuild = process.argv[2] is 'build'

config = require('./config')
config.debug = false if isBuild


#=========================================================================================
# Settings
#=========================================================================================
RELOAD_TRIGGERS = ['rs', 'regulp']

ASSETS_NAME = 'fe_assets'

PUBLIC_LOCATION = './public'
ASSETS_LOCATION = "#{PUBLIC_LOCATION}/#{ASSETS_NAME}"

MINIFIED_NAME = suffix: '.min'

TMP_FOLER = './.tmp'
SOURCE_FOLDER = './.source'

FONTS_LOCATION = "#{PUBLIC_LOCATION}/fonts"
STYLES_LOCATION = "./app/styles"

#=========================================================================================
# Reporters
#=========================================================================================
pathNormalize = (path)->
  "./#{path.replace("#{__dirname}/", '')}"

sourcesNormalize = (paths)->
  paths = [paths] if !_.isArray(paths)
  paths.map(pathNormalize)

benchmarkReporter = (action, startTime)->
  console.log(chalk.magenta("#{action} in #{((Date.now() - startTime) / 1000).toFixed(2)}s"))

watchReporter = (e)->
  console.log(chalk.cyan("File #{pathNormalize(e.path)} #{e.type}, flexing 💪"))

errorReporter = (e)->
  stack = e.stack or e
  console.log(chalk.bold.red("Build error!\n#{stack}"))
  # process.exit(1) if isBuild


#=========================================================================================
# Helpers
#=========================================================================================
dropTmpFolder = ->
  fs.removeSync(TMP_FOLER)

replaceFontello = (zipFile, done) ->
  [folderName] = _.last(zipFile.split('/')).split('.')

  SOURCE = "#{TMP_FOLER}/#{folderName}"
  FONT_LOCATION = "#{FONTS_LOCATION}/fontello"

  unless fs.ensureDirSync(FONT_LOCATION)
    fs.mkdirsSync(FONT_LOCATION)

  console.log(chalk.cyan('Extract new zip file...'))

  fs.createReadStream(zipFile).pipe(unzip.Extract(path: TMP_FOLER)).on 'close', ->
    console.log(chalk.cyan('Replacing files...'))

    fs.copySync("#{SOURCE}/font", "#{FONT_LOCATION}", clobber: true)
    fs.copySync("#{SOURCE}/css/nebenan-codes.css", "#{STYLES_LOCATION}/fonts/fontello_codes.css")
    dropTmpFolder()
    done?()

installFontello = ->
  console.log(chalk.cyan('Extract old zip file...'))

  glob "#{SOURCE_FOLDER}/fontello-*.zip", (err, [oldZip]) ->
    [folderName] = _.last(oldZip.split('/')).split('.')

    fs.createReadStream(oldZip).pipe(unzip.Extract(path: TMP_FOLER)).on 'close', ->
      config = "#{TMP_FOLER}/#{folderName}/config.json"

      console.log(chalk.cyan('Getting session url...'))

      fontello.apiRequest { config }, (sessionUrl) ->
        open(sessionUrl)
        dropTmpFolder()

        console.log(chalk.green('Press "ENTER" to start download (save session in browser before downloading)'))

        process.stdin.setRawMode(true)
        process.stdin.resume()
        process.stdin.on 'data', ([keyCode]) ->
          return unless keyCode is 13

          console.log(chalk.cyan('Download new zip file...'))

          stream = needle.get "#{sessionUrl}/get", (err, res, body) ->
            # Getting file name
            regexp = /filename=(.*)/gi
            [full, filename] = regexp.exec(res.headers['content-disposition'])

            newZip = "#{SOURCE_FOLDER}/#{filename}"

            fs.writeFile(newZip, body, ->
              fs.removeSync(oldZip)
              replaceFontello(newZip, -> process.exit())
            )

#=========================================================================================
# Compilers
#=========================================================================================
compileJavascripts = (src, options)->
  executor = (resolve, reject)->
    opts =
      entries: src
      extensions: ['.coffee', '.cjsx']
      debug: config.debug
      cache: {}
      packageCache: {}
      fullPaths: config.debug

    bundler = browserify(opts)
    bundler = watchify(bundler) if options.watch

    bundler.transform(coffeeReactify)

    compile = (files)->
      startTime = Date.now()

      watchReporter(path: file, type: 'changed') for file in files if files

      bundler
        .bundle()
        .on('error', errorReporter)
        .pipe(source(options.name))
        .pipe(gulp.dest(options.dest))
        .pipe(connect.reload())
        .on('end', ->
          benchmarkReporter("Browserified #{sourcesNormalize(src)}", startTime)
          resolve()
        )

    watchifyCompilers.push(compile)

    # bundler.on('file', (file)-> console.log(chalk.cyan("Browserifying #{pathNormalize(file)}")))
    bundler.on('update', compile) if options.watch
    compile()

  new Promise(executor)

compileStylesheets = (src, options)->
  executor = (resolve, reject)->
    startTime = Date.now()

    gulp
      .src(src)
      .pipe(stylus(
        errors: config.debug
        sourcemaps: config.debug
        use: [ nib() ]
        paths: [
          "#{__dirname}/app/scripts"
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

compileTemplates = (src, options)->
  generateAssetsMap = ->
    hash = {}
    for key, value of require("#{ASSETS_LOCATION}/hashmap.json")
      hash[key.replace('.min', '')] = value

    hash

  executor = (resolve, reject)->
    startTime = Date.now()

    assetsHashMap = generateAssetsMap() if isBuild

    injectAsset = (name)->
      _orig = name

      name = assetsHashMap[name] if isBuild
      errorReporter("Templates compiler: \"#{_orig}\" asset not found!") unless name

      "/#{ASSETS_NAME}/#{name}"

    injectConfig = (key)->
      if key
        clientConfig = _.merge(_.cloneDeep(config[key]), _.pick(config, 'debug', 'environment'))
      else
        clientConfig = _.cloneDeep(config)

      "<script>__$$config__ = #{sanitize(JSON.stringify(clientConfig))};</script>"

    gulp
      .src(src)
      .pipe(template(
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
processJavascripts = (options = {})->
  executor = (src, name, cssName)->
    (resolve)->
      settings = _.extend {}, options,
        name: name
        dest: ASSETS_LOCATION

      resolve(compileJavascripts(src, settings))

  new Promise(executor("#{__dirname}/app/scripts/index.coffee", 'app.js'))

processStylesheets = (options = {})->
  executor = (src, name)->
    (resolve)->
      settings = _.extend {}, options,
        name: name
        dest: ASSETS_LOCATION

      resolve(compileStylesheets(src, settings))

  new Promise(executor("#{__dirname}/app/styles/index.styl", 'app.css'))

processTemplates = (options = {})->
  executor = (src, dest)->
    (resolve)->
      settings = _.extend {}, options,
        dest: dest

      resolve(compileTemplates(src, settings))

  new Promise(executor([
    "#{__dirname}/app/templates/*.html",
    "!#{__dirname}/app/templates/_*.html"
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

gulp.task 'fontello', -> installFontello()

gulp.task 'scripts', -> processJavascripts()
gulp.task 'styles', -> processStylesheets()
gulp.task 'templates', -> processTemplates()

gulp.task 'serve', -> startDevserver()

gulp.task 'decache:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(decache(
      base: PUBLIC_LOCATION
      logMissing: true
    ))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:scripts', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.js", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(uglify(
      compress: { drop_console: true }
    ))
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:styles', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.css", "!#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.min-*"])
    .pipe(minifyCSS(
      processImport: false
      keepSpecialComments: 0
      aggressiveMerging: false
    ))
    .pipe(rename(MINIFIED_NAME))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'hashify', ->
  gulp
    .src("#{ASSETS_LOCATION}/*.min.*")
    .pipe(rev())
    .pipe(gulp.dest(ASSETS_LOCATION))
    .pipe(rev.manifest('hashmap.json'))
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'compress', ->
  gulp
    .src(["#{ASSETS_LOCATION}/*.min.*", "!#{ASSETS_LOCATION}/*.gz"])
    .pipe(gzip())
    .pipe(gulp.dest(ASSETS_LOCATION))

gulp.task 'minify:templates', ->
  gulp
    .src("#{PUBLIC_LOCATION}/**/*.html")
    .pipe(htmlmin(
      removeComments: true
      collapseWhitespace: true
      useShortDoctype: true
    ))
    .pipe(gulp.dest(PUBLIC_LOCATION))

gulp.task 'clean', (done) ->
  del([
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
      "#{__dirname}/app/**/*.styl"
      "#{__dirname}/app/vendor/**/*.css"
    ]
    gulp.watch(stylesheets).on 'change', (event)->
      watchReporter(event)
      processStylesheets()

    templates = [
      "#{__dirname}/app/templates/**/*.html"
    ]
    gulp.watch(templates).on 'change', (event)->
      watchReporter(event)
      processTemplates(watch: true)

    process.stdin.on 'data', (chunk)->
      if chunk.toString().replace(/[\r\n]/g, '') in RELOAD_TRIGGERS
        console.log(chalk.red('Triggered manual reload'))
        reprocessJavascripts()
        processStylesheets()
        processTemplates()
