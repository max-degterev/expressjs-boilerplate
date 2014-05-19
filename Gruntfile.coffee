module.exports = (grunt) ->
  time = require('time-grunt')(grunt)
  pkg = require('./package')
  cfg = require('config')

  grunt.initConfig
    pkg: pkg
    cfg: cfg


    clean:
      compile:
        src: 'public/assets'


    browserify:
      options:
        browserifyOptions: extensions: ['.coffee', '.jade']
        watch: grunt.cli.tasks[0] is 'watcher'

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
        src: 'app/stylesheets/index.styl'
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
      compile:
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


    watch:
      options:
        spawn: false
        interrupt: true
        dateFormat: (time)->
          grunt.log.writeln("Compiled in #{time}ms @ #{(new Date).toString()} 💪\n")

      # javascripts:
      #   files: [
      #     'app/javascripts/client/**/*.coffee'
      #     'app/javascripts/shared/**/*.coffee'
      #     'vendor/**/*.js'
      #     'vendor/**/*.coffee'
      #     'app/templates/client/**/*.jade'
      #     'app/templates/shared/**/*.jade'
      #   ]
      #   tasks: ['browserify']

      stylesheets:
        files: [
          'app/stylesheets/**/*.styl'
          'vendor/**/*.css'
          'vendor/**/*.styl'
          '!app/stylesheets/static.styl'
        ]
        tasks: ['stylus:stylesheets']

      static:
        files: [
          'app/stylesheets/static.styl'
          'app/templates/static/**/*.jade'
        ]
        tasks: ['stylus:static', 'jade']


  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-contrib-stylus')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-htmlmin')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-hashify')
  grunt.loadNpmTasks('grunt-contrib-compress')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('default', [
    'clean'

    'browserify'
    'stylus'
    'jade'
  ])

  grunt.registerTask('watcher', [
    'browserify'
    'watch'
  ])

  grunt.registerTask('build', [
    'default'

    'cssmin'
    'htmlmin'
    'uglify'

    'hashify'

    'compress'
  ])
