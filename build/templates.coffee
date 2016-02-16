process = (src, options) ->
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

module.exports = (options = {}) ->
  executor = (src, dest) ->
    (resolve) ->
      settings = _.assignIn {}, options,
        dest: dest

      resolve(compileTemplates(src, settings))

  new Promise(executor([
    "#{__dirname}/templates/*.html",
    "!#{__dirname}/templates/_*.html"
  ], PUBLIC_LOCATION))
