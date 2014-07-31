glob = require 'glob'


#=== Files
#==============================================================================================
DIRS = ['src', 'test', 'dist', 'build', 'tmp', 'vendor']

COMPONENTS = [
  'utils'
  'event'
  'observable'
  'supports'
]

VENDOR_FILES =
  lodash: ['lodash', 'dist', 'lodash.min.js']
  jquery: ['jquery', 'jquery.min.js']

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


#=== Utils
#==============================================================================================
FILES = do ->
  _path = []
  f = {}

  f.push = (paths...) ->
    _path.push paths... if paths.length
    f

  f.join = ->
    f.push arguments...
    paths = _path
    _path = []
    paths.join '/'

  DIRS.forEach (dir) ->
    Object.defineProperty f, dir,
      get: -> f.push dir

  Object.defineProperty f, 'relative',
    get: -> f.push '.'

  Object.defineProperty f, 'path',
    get: -> f.join()

  f


#=== Task config
#==============================================================================================
gruntConfig = {}

#  Coffee
#-----------------------------------------------
gruntConfig.coffee =
  src:
    expand: true
    cwd: FILES.src.path
    dest: FILES.tmp.src.path
    src: ['**/*.coffee']
    ext: '.js'

  test:
    expand: true
    cwd: FILES.test.path
    dest: FILES.tmp.test.path
    src: ['**/*.coffee']
    ext: '.js'

  release:
    expand: true
    cwd: FILES.src.path
    dest: FILES.tmp.src.path
    src: ['**/*.coffee']
    ext: '.js'
    options:
      bare: true


#  Browserify
#-----------------------------------------------
gruntConfig.browserify =
  options:
    alias: []

  main:
    src: [FILES.tmp.src.join('observable', 'index.js')]
    dest: FILES.build.join 'leaf.js'
    options:
      external: []

  vendor:
    src: []
    dest: FILES.build.join 'vendor.js'

for alias, file of VENDOR_FILES
  file = FILES.relative.vendor.join file...
  gruntConfig.browserify.options.alias.push "#{file}:#{alias}"
  gruntConfig.browserify.main.options.external.push file


#  Clean
#-----------------------------------------------
gruntConfig.clean =
  tmp: FILES.tmp.path


#  Simple mocha
#-----------------------------------------------
gruntConfig.simplemocha =
  options:
    globals: ['expect']
    ui: 'bdd'
    reporter: 'spec'
    colors: true

  all:
    src: [FILES.tmp.test.join('**', '*_spec.js')]

for component in COMPONENTS
  gruntConfig.simplemocha[component] =
    src: [FILES.tmp.test.join(component, '**', '*_spec.js')]


#  Concat
#-----------------------------------------------
gruntConfig.concat =
  src:
    options:
      banner: BANNER
    src: [FILES.build.join('leaf.js')]
    dest: FILES.build.join 'leaf.js'


#  Uglify
#-----------------------------------------------
gruntConfig.uglify =
  src:
    options:
      banner: BANNER
      report: 'gzip'

    src: [FILES.build.join('leaf.js')]
    dest: FILES.build.join 'leaf.min.js'


#  Watch
#-----------------------------------------------
gruntConfig.watch =
  options:
    spawn: false

  src:
    files: FILES.src.join '**', '*.coffee'
    tasks: ['newer:coffee:src']

  test:
    files: FILES.test.join '**', '*.coffee'
    tasks: ['newer:coffee:test']

  karma:
    files: [
      FILES.tmp.src.join('**', '*.js')
      FILES.tmp.test.join('**', '*_spec.js')
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

