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
      job_service:
        src: ["test/**/JobService-spec.coffee"]

  grunt.loadNpmTasks "grunt-mocha-test"
  # grunt.loadNpmTasks "grunt-env"

  # Test tasks.
  grunt.registerTask "jobservice", ["mochaTest:job_service"]
  grunt.registerTask "test", ["mochaTest"]