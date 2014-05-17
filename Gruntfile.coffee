module.exports = (grunt) ->
  time = require('time-grunt')(grunt)
  pkg = require('./package')
  cfg = require('config')

  grunt.initConfig
    pkg: pkg
    cfg: cfg


    clean:
      compile:
        src: ['.tmp', 'public/assets']


    browserify:
      options:
        browserifyOptions: extensions: ['.coffee']
        require: Object.keys(pkg['browserify-shim'])
        transform: ["coffeeify", "browserify-shim"]

      compile:
        src: 'app/javascripts/client/index.coffee'
        dest: 'public/assets/app.js'


    stylus:
      stylesheets:
        options:
          compress: false
          'include css': true
          urlfunc: 'embedurl'
          linenos: true
          define:
            '$version': '<%= pkg.version %>'
        src: 'app/stylesheets/app.styl'
        dest: 'public/assets/app.css'

      static:
        options:
          compress: false
          'include css': true
          urlfunc: 'embedurl'
          linenos: true
          define:
            '$version': '<%= pkg.version %>'
        src: 'app/stylesheets/static.styl'
        dest: 'public/static.css'


    jade:
      templates:
        options:
          pretty: true
          compileDebug: false
          client: true
          node: true
          processName: (file)-> file.replace(/app\/templates\/client\/([\w\/]+).jade/gi, '$1')
        src: 'app/templates/client/**/*.jade'
        dest: '.tmp/jst.js'

      static:
        options:
          pretty: true
          compileDebug: false

        expand: true
        cwd: 'app/templates/static'
        src: ['**/*.jade', '!**/_*.jade']
        dest: 'public'
        ext: '.html'


    cssmin:
      stylesheets:
        src: 'public/assets/app.css'
        dest: 'public/assets/app.min.css'

      static:
        src: 'public/static.css'
        dest: 'public/static.css'


    htmlmin:
      compile:
        options:
          removeComments: true
          collapseWhitespace: true
          collapseBooleanAttributes: true
          removeAttributeQuotes: true
          removeRedundantAttributes: true
          useShortDoctype: true
          removeEmptyAttributes: true
          # removeOptionalTags: true
        expand: true
        src: 'public/*.html'
        dest: './'


    uglify:
      compile:
        src: 'public/assets/app.js'
        dest: 'public/assets/app.min.js'


    hashify:
      options:
        basedir: 'public/assets/'
        hashmap: 'hashmap.json'

      javascripts:
        src: 'public/assets/app.min.js'
        dest: 'app.min.{{hash}}.js'
        key: 'app.js'

      stylesheets:
        src: 'public/assets/app.min.css'
        dest: 'app.min.{{hash}}.css'
        key: 'app.css'


    compress:
      compile:
        options:
          mode: 'gzip'
        expand: true
        src: 'public/assets/*.min.*.*'
        dest: './'

      static:
        options:
          mode: 'gzip'
        expand: true
        src: 'public/*.css'
        dest: './'


    # imagemin:
    #   options:
    #     optimizationLevel: 7
    #   files:
    #     expand: true
    #     src: [
    #       'public/images/**/*.jpg'
    #       'public/images/**/*.jpeg'
    #       'public/images/**/*.png'
    #     ]
    #     dest: './'


    watch:
      options:
        spawn: false
        interrupt: true
        dateFormat: (time)->
          grunt.log.writeln("Compiled in #{time}ms @ #{(new Date).toString()} 💪\n")

      javascripts:
        files: [
          'app/javascripts/client/**/*.coffee'
          'app/javascripts/shared/**/*.coffee'
          'vendor/**/*.js'
          'vendor/**/*.coffee'
          '.tmp/jst.js'
        ]
        tasks: ['browserify']

      styles:
        files: [
          'app/stylesheets/**/*.styl'
          'vendor/**/*.css'
          'vendor/**/*.styl'
          '!app/stylesheets/static.styl'
        ]
        tasks: ['stylus:stylesheets']

      templates:
        files: [
          'app/templates/client/**/*.jade'
          'app/templates/shared/**/*.jade'
        ]
        tasks: ['jade:templates']

      static:
        files: [
          'app/stylesheets/static.styl'
          'app/templates/static/**/*.jade'
        ]
        tasks: ['stylus:static', 'jade:static']

      # images:
      #   files: [
      #     'public/images/**/*.jpg'
      #     'public/images/**/*.jpeg'
      #     'public/images/**/*.png'
      #   ]
      #   tasks: ['imagemin']


  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-contrib-stylus')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-htmlmin')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-hashify')
  grunt.loadNpmTasks('grunt-contrib-compress')
  # grunt.loadNpmTasks('grunt-contrib-imagemin')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('default', [
    'clean'

    'jade' # has to go before browserify
    'browserify'
    'stylus'
  ])

  grunt.registerTask('build', [
    'default'

    'cssmin'
    'htmlmin'
    'uglify'

    'hashify'

    'compress'
    # 'imagemin' # rely on minification during development
  ])
