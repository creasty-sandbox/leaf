glob = require 'glob'


#=== Files
#==============================================================================================
SRC_DIR    = 'src'
TEST_DIR   = 'test'
DIST_DIR   = 'dist'
BUILD_DIR  = 'build'
TMP_DIR    = 'tmp'
VENDOR_DIR = 'vendor'

COMPONENTS = [
  'utils'
  'event'
  'observable'
  'supports'
]

BANNER =  """
  /*!
   * <%= pkg.title || pkg.name %> - v<%= pkg.version %> (<%= grunt.template.today("yyyy-mm-dd") %>)
   *
   * @author <%= pkg.author %>
   * @url <%= pkg.url %>
   * @copyright <%= grunt.template.today("yyyy") %> <%= pkg.author %>
   * @license <%= pkg.license %>
   */

  """


#=== Task config
#==============================================================================================
gruntConfig = {}

#  Coffee
#-----------------------------------------------
gruntConfig.coffee =
  src:
    expand: true
    cwd: SRC_DIR
    dest: "#{TMP_DIR}/#{SRC_DIR}"
    src: ['**/*.coffee']
    ext: '.js'

  test:
    expand: true
    cwd: TEST_DIR
    dest: "#{TMP_DIR}/#{TEST_DIR}"
    src: ['**/*.coffee']
    ext: '.js'

  release:
    expand: true
    cwd: SRC_DIR
    dest: "#{TMP_DIR}/#{SRC_DIR}"
    src: ['**/*.coffee']
    ext: '.js'
    options:
      bare: true


#  Browserify
#-----------------------------------------------
gruntConfig.browserify =
  options:
    alias: [
      "./#{VENDOR_DIR}/lodash/dist/lodash.min.js:lodash"
      "./#{VENDOR_DIR}/jquery/jquery.min.js:jquery"
    ]

  main:
    src: ["#{TMP_DIR}/#{SRC_DIR}/observable/index.js"]
    dest: "#{BUILD_DIR}/leaf.js"
    options:
      external: [
        "./#{VENDOR_DIR}/lodash/dist/lodash.min.js"
        "./#{VENDOR_DIR}/jquery/jquery.min.js"
      ]

  vendor:
    src: []
    dest: "#{BUILD_DIR}/vendor.js"


#  Clean
#-----------------------------------------------
gruntConfig.clean =
  tmp: TMP_DIR


#  Simple mocha
#-----------------------------------------------
gruntConfig.simplemocha =
  options:
    globals: ['expect']
    ui: 'bdd'
    reporter: 'spec'
    colors: true

  all:
    src: ["#{TMP_DIR}/#{TEST_DIR}/**/*_spec.js"]

for component in COMPONENTS
  gruntConfig.simplemocha[component] =
    src: ["#{TMP_DIR}/#{TEST_DIR}/#{component}/**/*_spec.js"]


#  Concat
#-----------------------------------------------
gruntConfig.concat =
  src:
    options:
      banner: BANNER
    src: ["#{BUILD_DIR}/leaf.js"]
    dest: "#{BUILD_DIR}/leaf.js"


#  Uglify
#-----------------------------------------------
gruntConfig.uglify =
  src:
    options:
      banner: BANNER
      report: 'gzip'

    src: ["#{BUILD_DIR}/leaf.js"]
    dest: "#{BUILD_DIR}/leaf.min.js"


#  Watch
#-----------------------------------------------
gruntConfig.watch =
  options:
    spawn: false

  src:
    files: "#{SRC_DIR}/**/*.coffee"
    tasks: ['newer:coffee:src']

  test:
    files: "#{TEST_DIR}/**/*.coffee"
    tasks: ['newer:coffee:test']

  karma:
    files: [
      "#{TMP_DIR}/#{SRC_DIR}/**/*.js"
      "#{TMP_DIR}/#{TEST_DIR}/**/*_spec.js"
    ]
    tasks: ['group_test']


#=== Grunt
#==============================================================================================
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks


  #  Config
  #-----------------------------------------------
  grunt.option 'force', true
  gruntConfig.pkg = grunt.file.readJSON 'package.json'
  grunt.initConfig gruntConfig


  #  Tasks
  #-----------------------------------------------
  group = grunt.option('group') ? 'all'
  grunt.registerTask 'group_test', ["simplemocha:#{group}"]

  grunt.registerTask 'dev', [
    'clean'
    'coffee:src'
    'watch:src'
  ]

  grunt.registerTask 'test', [
    'clean'
    'coffee:src'
    'coffee:test'
    'group_test'
    'watch'
  ]

  grunt.registerTask 'build', [
    'clean'
    'coffee:release'
    'browserify'
    'concat'
    'uglify'
  ]

  grunt.registerTask 'release', [
    # FIXME
    'build'
  ]

  grunt.registerTask 'default', ['dev']

