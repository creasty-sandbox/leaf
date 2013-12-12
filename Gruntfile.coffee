
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  #  Option
  #-----------------------------------------------
  filter = grunt.option 'filter'

  #  File list
  #-----------------------------------------------
  SRC_DIR  = 'src/'
  TEMP_DIR = 'tmp/'
  VENDOR_DIR = 'vendors/'

  files = (tmp) ->
    base = ''
    base += TEMP_DIR if tmp
    base += SRC_DIR

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
      'utils/array_diff_patch.coffee'
    ].map fn
    formatters: [
      'formatters/formatter.coffee'
      'formatters/html.coffee'
    ].map fn
    observable: [
      'observable/observable_base.coffee'
      'observable/observable_object.coffee'
      'observable/observable_array.coffee'
      'observable/observable.coffee'
    ].map fn
    template: [
      'template/template.coffee'
      'template/tokenizer.coffee'
      'template/parser.coffee'
      'template/custom_tags.coffee'
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

  files.src = files false
  files.tmp = files true

  files.vendor = [
    "#{VENDOR_DIR}jquery/jquery.min.js"
    "#{VENDOR_DIR}lodash/dist/lodash.min.js"
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
            files.src.headers...
            files.src.utils...
            # files.src.formatters...
            files.src.observable...
            # files.src.template...
            # files.src.core...
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
        helpers: [
          'vendors/jasmine-jquery/lib/jasmine-jquery.js'
          'tmp/spec/helpers/*.js'
        ]
        keepRunner: true
        vendor: files.vendor

      utils:
        src: [
          files.tmp.headers...
          files.tmp.utils...
        ]
        options:
          specs: ['tmp/spec/utils/*.js']

      observable:
        src: [
          files.tmp.headers...
          files.tmp.utils...
          files.tmp.observable...
        ]
        options:
          specs: ['tmp/spec/observable/*.js']

      template:
        src: [
          files.tmp.headers...
          files.tmp.utils...
          files.tmp.formatters...
          files.tmp.observable...
          files.tmp.template...
        ]
        options:
          specs: ['tmp/spec/template/*.js']

      core:
        src: [
          files.tmp.headers...
          files.tmp.utils...
          files.tmp.formatters...
          files.tmp.observable...
          files.tmp.template...
          files.tmp.core...
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

