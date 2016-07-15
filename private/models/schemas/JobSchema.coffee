mongoose = require("mongoose")
validators = require('mongoose-validators')
EntitySchemaPlugin = require("./plugins/EntitySchemaPlugin")
schemaHelpers = require("../../lib/schemahelpers")

JobSchema = new mongoose.Schema
  _id:
    type: String
    default: schemaHelpers.idDefault("job")
  url:
    type: String
    required: yes
    validate: validators.isURL()
  status:
    type: String
    enum: ["added", "failed", "complete", "retrying", "running", "queued"]
    required: yes
    index: yes
    default: "added"
  result:
    type: mongoose.Schema.Types.Mixed

JobSchema.plugin(EntitySchemaPlugin)

module.exports = JobSchema
