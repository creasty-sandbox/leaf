
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
  ]
  utils: [
    'lodash/*.coffee'
    'util.coffee'
    'class.coffee'
    'error.coffee'
    'cache.coffee'
    'inflector.coffee'
    'identifiable.coffee'
    'cacheable.coffee'
    'accessible.coffee'
    'hookable.coffee'
    'array_diff_patch.coffee'
    'remove_js_literals.coffee'
  ]
  event: [
    'event.coffee'
    'event_emitter.coffee'
  ]
  support: [
    'support.coffee'
    'string.coffee'
    'number.coffee'
    'date.coffee'
  ]
  observable: [
    'affected_keypath_tracker.coffee'
    'observable.coffee'
    'observable_base.coffee'
    'observable_object.coffee'
    'observable_array.coffee'
    'expression_compiler.coffee'
  ]
  template: [
    'template.coffee'
    'preformatter.coffee'
    'tokenizer.coffee'
    'parser.coffee'
    'dom_generator.coffee'
  ]
  _object: [
    'object.coffee'
  ]
  view: [
    'view.coffee'
    'view_array.coffee'
    'conditional_view.coffee'
    'iterator_view.coffee'
    'component.coffee'
    'render.coffee'
    'yield.coffee'
    'content_for.coffee'
  ]
  framework: [
    # 'router.coffee'
    # 'navigator.coffee'
    'model.coffee'
    'collection.coffee'
    'controller.coffee'
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
  support: [
    'headers'
    'utils'
    'event'
  ]
  observable: [
    'headers'
    'utils'
    'event'
    'support'
  ]
  template: [
    'headers'
    'utils'
    'event'
    'support'
    'observable'
  ]
  view: [
    'headers'
    'utils'
    'event'
    'support'
    'observable'
    'template'
    'object'
  ]
  framework: [
    'headers'
    'utils'
    'event'
    'support'
    'observable'
    'template'
    'object'
    'view'
  ]


#=== Utils
#==============================================================================================
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


#=== Task config
#==============================================================================================
gruntConfig = {}

# Coffee
gruntConfig.coffee =
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
      'dist/leaf.js': files.all 'framework', 'src'

# Clean
gruntConfig.clean =
  tmp: TMP_DIR

# Concat
gruntConfig.concat =
  src:
    options:
      banner: '<%= meta.banner %>'
    files:
      'dist/leaf.js': ['dist/leaf.js']

# Uglify
gruntConfig.uglify =
  src:
    options:
      banner: '<%= meta.banner %>'
      report: 'gzip'
    files:
      'dist/leaf.min.js': ['dist/leaf.js']

# Jasmine
gruntConfig.jasmine =
  options:
    helpers: [
      "#{VENDOR_DIR}jasmine-jquery/lib/jasmine-jquery.js"
      "#{TMP_DIR}#{SPEC_DIR}helpers/*.js"
    ]
    keepRunner: true
    vendor: files.vendor

do ->
  c = gruntConfig.jasmine

  for name of FILE_DEPENDENCIES
    c[name] =
      src: files.all name
      options:
        specs: files.specTmp[name]

# Watch
gruntConfig.watch =
  options:
    spawn: false

  coffee:
    files: "#{SRC_DIR}**/*.coffee"
    tasks: ['newer:coffee:src']

  coffee_test:
    files: "#{SPEC_DIR}**/*.coffee"
    tasks: ['newer:coffee:test']

  jasmine:
    files: [
      "#{TMP_DIR}#{SPEC_DIR}**/*.js"
      "#{TMP_DIR}#{SRC_DIR}**/*.js"
    ]
    tasks: ['group_test']


#=== Banner
#==============================================================================================
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


#=== Grunt
#==============================================================================================
module.exports = (grunt) ->

  #  Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  #  Config
  #-----------------------------------------------
  gruntConfig.pkg = grunt.file.readJSON 'package.json'
  gruntConfig.meta = banner: BANNER
  grunt.initConfig gruntConfig

  #  Tasks
  #-----------------------------------------------
  grunt.option 'force', true

  testGroup = grunt.option 'group'
  grunt.registerTask 'group_test', [if testGroup then "jasmine:#{testGroup}" else 'jasmine']

  grunt.registerTask 'default', ['dev']
  grunt.registerTask 'dev', ['clean', 'coffee:src', 'watch:coffee']
  grunt.registerTask 'test', ['clean', 'coffee:src', 'coffee:test', 'group_test', 'watch']
  grunt.registerTask 'release', ['clean', 'coffee:release', 'concat', 'uglify']

