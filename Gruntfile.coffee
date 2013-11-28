
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  #  File list
  #-----------------------------------------------
  srcfiles =
    utils: [
      'src/utils/utils.coffee'
      'src/utils/inflection.coffee'
      'src/utils/event.coffee'
    ]
    observable: [
      'src/observable/observable.coffee'
    ]
    template: [
      'src/template/rivets.coffee'
      'src/template/view.coffee'
      'src/template/bindings.coffee'
      'src/template/parsers.coffee'
      'src/template/keypath_observer.coffee'
      'src/template/binders.coffee'
      'src/template/adapters.coffee'
    ]
    main: [
      'src/leaf.coffee'
      'src/object.coffee'
      'src/router.coffee'
      'src/navigator.coffee'
      'src/model.coffee'
      'src/controller.coffee'
      'src/view.coffee'
      'src/app.coffee'
    ]


  #  Config
  #-----------------------------------------------
  grunt.initConfig

    # Package
    pkg: grunt.file.readJSON 'package.json'

    # Meta
    meta:
     banner:
        """
        /*!
         * <%= pkg.title || pkg.name %> - v<%= pkg.version %> (<%= grunt.template.today("yyyy-mm-dd") %>)
         *
         * @author <%= pkg.author %>
         * @url <%= pkg.url %>
         * @copyright <%= grunt.template.today("yyyy") %> <%= pkg.author %>
         * @license <%= pkg.license %>
         */

        """

    # Coffee
    coffee:
      src:
        options:
          join: true
          bare: true
        files:
          'tmp/dist/template.js': srcfiles.template
          'tmp/dist/main.js': [
            srcfiles.utils...
            srcfiles.observable...
            srcfiles.main...
          ]

      test:
        expand: true
        cwd: 'spec'
        src: ['**/*.coffee']
        dest: 'tmp/spec'
        ext: '.js'

      release:
        options:
          join: true
        files:
          'dist/leaf.js': [
            srcfiles.utils...
            srcfiles.observable...
            srcfiles.template...
            srcfiles.main...
          ]

    # Concat
    concat:
      src:
        options:
          banner: '<%= meta.banner %>'
        files:
          'dist/template.js': 'tmp/dist/template.js'

    # Uglify
    uglify:
      src:
        options:
          banner: '<%= meta.banner %>'
          report: 'gzip'
        files:
          'dist/template.min.js': 'dist/template.js'

    # Jasmine
    jasmine:
      options:
        force: true
        helpers: ['tmp/spec/helpers/*.js', 'spec/lib/*.js']
        vendor: [
          'vendors/jquery/jquery.min.js'
          'vendors/lodash/dist/lodash.min.js'
        ]

      template:
        src: 'tmp/dist/template.js'
        options:
          specs: ['tmp/spec/template/*.js']

      main:
        src: 'tmp/dist/main.js'
        options:
          specs: ['tmp/spec/*.js', 'tmp/spec/utils/*.js', 'tmp/src/observable/*.js']

    # Watch
    watch:
      coffee:
        files: 'src/**/*.coffee'
        tasks: ['coffee:src']

      test:
        files: 'tmp/spec/**/*.js'
        tasks: ['jasmine:main']


  #  Tasks
  #-----------------------------------------------
  grunt.registerTask 'default', ['dev']
  grunt.registerTask 'dev', ['coffee:src', 'watch:coffee']
  grunt.registerTask 'test', ['coffee:src', 'coffee:test', 'jasmine', 'watch']
  grunt.registerTask 'release', ['coffee', 'concat', 'uglify']

