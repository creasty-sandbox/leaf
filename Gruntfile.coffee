
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  #  Option
  #-----------------------------------------------
  filter = grunt.option 'filter'

  #  File list
  #-----------------------------------------------
  files = (tmp) ->
    base = ''
    base += 'tmp/' if tmp
    base += 'src/'

    fn = (path) -> base + (if tmp then path.replace('.coffee', '.js') else path)

    headers: [
      'leaf.coffee'
      'constants.coffee'
    ].map fn
    utils: [
      'utils/utils.coffee'
      'utils/inflection.coffee'
      'utils/event.coffee'
      'utils/cache.coffee'
      'utils/object.coffee'
    ].map fn
    observable: [
      'observable/observable_base.coffee'
      'observable/observable_object.coffee'
      'observable/observable_array.coffee'
      'observable/observable.coffee'
    ].map fn
    template: [
      'template/tokenizer.coffee'
      'template/parser.coffee'
    ].map fn
    core: [
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

  vendorfiles = [
    'vendors/jquery/jquery.min.js'
    'vendors/lodash/dist/lodash.min.js'
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
            srcfiles.headers...
            # srcfiles.utils...
            srcfiles.observable...
            # srcfiles.template...
            # srcfiles.core...
          ]

    # Concat
    concat:
      src:
        options:
          banner: '<%= meta.banner %>'
        files:
          'dist/leaf.js': ['dist/leaf.js']

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
        vendor: vendorfiles

      utils:
        src: [
          tmpfiles.headers...
          tmpfiles.utils...
        ]
        options:
          specs: ['tmp/spec/utils/*.js']

      observable:
        src: [
          tmpfiles.headers...
          tmpfiles.utils...
          tmpfiles.observable...
        ]
        options:
          specs: ['tmp/spec/observable/*.js']

      template:
        src: [
          tmpfiles.headers...
          tmpfiles.utils...
          tmpfiles.observable...
          tmpfiles.template...
        ]
        options:
          specs: ['tmp/spec/template/*.js']

      core:
        src: [
          tmpfiles.headers...
          tmpfiles.utils...
          tmpfiles.observable...
          tmpfiles.template...
          tmpfiles.core...
        ]
        options:
          specs: ['tmp/spec/core/*.js']

    # Watch
    watch:
      options:
        spawn: false

      coffee:
        files: 'src/**/*.coffee'
        tasks: ['coffee:src']

      coffee_test:
        files: 'spec/**/*.coffee'
        tasks: ['coffee:test']

      jasmine:
        files: ['tmp/spec/**/*.js', 'tmp/src/**/*.js']
        tasks: ['filtered_test']


  #  Tasks
  #-----------------------------------------------
  grunt.option 'force', true
  grunt.registerTask 'default', ['dev']

  filteredTest = if filter then "jasmine:#{filter}" else 'jasmine'
  grunt.registerTask 'filtered_test', [filteredTest]

  grunt.registerTask 'dev', ['coffee:src', 'watch:coffee']
  grunt.registerTask 'test', ['coffee:src', 'coffee:test', 'filtered_test', 'watch']
  grunt.registerTask 'release', ['coffee:release', 'concat', 'uglify']

