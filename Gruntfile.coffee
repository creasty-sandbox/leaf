
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  #  File list
  #-----------------------------------------------
  files = (tmp) ->
    base = ''
    base += 'tmp/' if tmp
    base += 'src/'

    fn = (path) -> base + (if tmp then path.replace('.coffee', '.js') else path)

    utils: [
      'utils/utils.coffee'
      'utils/inflection.coffee'
      'utils/event.coffee'
    ].map fn
    observable: [
      'observable/base.coffee'
      'observable/object.coffee'
      'observable/array.coffee'
      'observable/observable.coffee'
    ].map fn
    template: [
      'template/rivets.coffee'
      'template/view.coffee'
      'template/bindings.coffee'
      'template/parsers.coffee'
      'template/keypath_observer.coffee'
      'template/binders.coffee'
      'template/adapters.coffee'
    ].map fn
    core: [
      'core/leaf.coffee'
      'core/object.coffee'
      'core/router.coffee'
      'core/navigator.coffee'
      'core/model.coffee'
      'core/controller.coffee'
      'core/view.coffee'
      'core/app.coffee'
    ].map fn

  srcfiles = files false
  tmpfiles = files true


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
          bare: true
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'tmp/src'
        ext: '.js'

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
            srcfiles.core...
          ]

    # Concat
    concat:
      src:
        options:
          banner: '<%= meta.banner %>'
        files:
          'dist/leaf.js': ['tmp/dist/leaf.js']

    # Uglify
    uglify:
      src:
        options:
          banner: '<%= meta.banner %>'
          report: 'gzip'
        files:
          'dist/leaf.min.js': ['dist/leaf.js']

    # Jasmine
    jasmine:
      options:
        helpers: ['spec/lib/*.js', 'tmp/spec/helpers/*.js']
        keepRunner: true
        vendor: [
          'vendors/jquery/jquery.min.js'
          'vendors/lodash/dist/lodash.min.js'
        ]

      utils:
        src: tmpfiles.utils
        options:
          specs: ['tmp/spec/utils/*.js']

      observable:
        src: tmpfiles.observable
        options:
          specs: ['tmp/spec/observable/*.js']

      template:
        src: [
          tmpfiles.utils...
          tmpfiles.observable...
          tmpfiles.template...
        ]
        options:
          specs: ['tmp/spec/template/*.js']

      core:
        src: [
          tmpfiles.utils...
          tmpfiles.observable...
          tmpfiles.template...
          tmpfiles.core...
        ]
        options:
          specs: ['tmp/spec/core/*.js']

    # Watch
    watch:
      coffee:
        files: 'src/**/*.coffee'
        tasks: ['coffee:src']

      coffee_test:
        files: 'spec/**/*.coffee'
        tasks: ['coffee:test']

      jasmine:
        files: 'tmp/spec/**/*.js'
        tasks: ['filtered_test']


  #  Tasks
  #-----------------------------------------------
  grunt.option 'force', true
  grunt.registerTask 'default', ['dev']

  filteredTest = if (filter = grunt.option('filter')) then "jasmine:#{filter}" else 'jasmine'
  grunt.registerTask 'filtered_test', [filteredTest]

  grunt.registerTask 'dev', ['coffee:src', 'watch:coffee']
  grunt.registerTask 'test', ['coffee:src', 'coffee:test', 'filtered_test', 'watch']
  grunt.registerTask 'release', ['coffee:release', 'concat', 'uglify']

