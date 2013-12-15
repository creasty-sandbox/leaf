
#=== Files
#==============================================================================================
DIST_DIR   = 'dist/'
SRC_DIR    = 'src/'
TMP_DIR    = 'tmp/'
SPEC_DIR   = 'spec/'
VENDOR_DIR = 'vendors/'

FILES =
  _headers: [
    'leaf.coffee'
    'constants.coffee'
  ]
  utils: [
    'utils.coffee'
    'inflection.coffee'
    'event.coffee'
    'cache.coffee'
    'object.coffee'
    'array_diff_patch.coffee'
  ]
  formatters: [
    'formatter.coffee'
    'html.coffee'
  ]
  observable: [
    'observable_base.coffee'
    'observable_object.coffee'
    'observable_array.coffee'
    'observable.coffee'
  ]
  template: [
    'template.coffee'
    'tokenizer.coffee'
    'parser.coffee'
    'view.coffee'
    'custom_tags.coffee'
  ]
  core: [
    'object.coffee'
    'router.coffee'
    'navigator.coffee'
    'model.coffee'
    'controller.coffee'
    'view.coffee'
    'app.coffee'
  ]

VENDOR_FILES = [
  'jquery/jquery.min.js'
  'lodash/dist/lodash.min.js'
]

FILE_DEPENDENCIES =
  utils: [
    'headers'
  ]
  observable: [
    'headers'
    'utils'
  ]
  template: [
    'headers'
    'utils'
    'formatter'
    'observable'
  ]
  core: [
    'headers'
    'utils'
    'formatters'
    'observable'
    'template'
  ]


#=== Grunt
#==============================================================================================
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  #  Option
  #-----------------------------------------------
  filter = grunt.option 'filter'

  #  Files
  #-----------------------------------------------
  files = do ->
    f =
      src: {}
      tmp: {}
      specSrc: {}
      specTmp: {}

    for name, set of FILES
      if '_' == name[0]
        name = name[1..]
        dir = ''
      else
        dir = name + '/'

      f.src[name] = set.map (path) ->
        SRC_DIR + dir + path
      f.tmp[name] = set.map (path) ->
        TMP_DIR + SRC_DIR + dir + path.replace('.coffee', '.js')
      f.specSrc[name] = set.map (path) ->
        SPEC_DIR + dir + path.replace('.coffee', '_spec.coffee')
      f.specTmp[name] = set.map (path) ->
        TMP_DIR + SPEC_DIR + dir + path.replace('.coffee', '_spec.js')

    f.vendor = VENDOR_FILES.map (path) ->
      VENDOR_DIR + path

    f

  files.all = (name, type = 'tmp') ->
    all = []

    all.push files[type][dep]... for dep in FILE_DEPENDENCIES[name] ? []
    all.push files[type][name]...

    all

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
        cwd: SRC_DIR
        dest: TMP_DIR + SRC_DIR
        src: ['**/*.coffee']
        ext: '.js'

      test:
        expand: true
        cwd: SPEC_DIR
        dest: TMP_DIR + SPEC_DIR
        src: ['**/*.coffee']
        ext: '.js'

      release:
        options:
          join: true
        files:
          'dist/leaf.js': files.all 'observable', 'src'

    # Concat
    concat:
      src:
        options:
          banner: '<%= meta.banner %>'
        files:
          cwd: DIST_DIR
          dest: DIST_DIR
          src: ['leaf.js']

    # Uglify
    uglify:
      src:
        options:
          banner: '<%= meta.banner %>'
          report: 'gzip'
        files:
          cwd: DIST_DIR
          dest: DIST_DIR
          src: ['leaf.js']
          ext: '.min.js'

    # Jasmine
    jasmine:
      options:
        helpers: [
          "#{VENDOR_DIR}jasmine-jquery/lib/jasmine-jquery.js"
          "#{TMP_DIR}#{SPEC_DIR}helpers/*.js"
        ]
        keepRunner: true
        vendor: files.vendor

      utils:
        src: files.all 'utils'
        options:
          specs: files.specTmp.utils

      observable:
        src: files.all 'observable'
        options:
          specs: files.specTmp.observable

      template:
        src: files.all 'template'
        options:
          specs: files.specTmp.template

      core:
        src: files.all 'core'
        options:
          specs: files.specTmp.core

    # Watch
    watch:
      options:
        spawn: false

      coffee:
        files: "#{SRC_DIR}**/*.coffee"
        tasks: ['coffee:src']

      coffee_test:
        files: "#{SPEC_DIR}**/*.coffee"
        tasks: ['coffee:test']

      jasmine:
        files: [
          "#{TMP_DIR}#{SPEC_DIR}**/*.js"
          "#{TMP_DIR}#{SRC_DIR}**/*.js"
        ]
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

