# process.env.LOG_LEVEL = 'error'

module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig

    # Metadata.
    pkg: grunt.file.readJSON("package.json")
    banner: "/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %>"

    #    env:
    #      test:
    #        LOG_LEVEL: 'error'

    # Task configuration.
    mochaTest:
      options:
        reporter: "spec"
        timeout: 60000
        require: "coffee-script"
        bail: yes
        clearRequireCache: yes
        globals: yes
      kue_service:
        src: ["test/**/KueService-spec.coffee"]

  grunt.loadNpmTasks "grunt-mocha-test"
  # grunt.loadNpmTasks "grunt-env"

  # Test tasks.
  grunt.registerTask "kueservice", ["mochaTest:kue_service"]
  grunt.registerTask "test", ["mochaTest"]