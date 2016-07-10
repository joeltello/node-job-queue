mongoose = require("mongoose")
EntitySchemaPlugin = require("./plugins/EntitySchemaPlugin")
schemaHelpers = require("../../lib/schemahelpers")

JobSchema = new mongoose.Schema
  _id:
    type: String
    default: schemaHelpers.idDefault("job")
  status:
    type: String
    enum: ["none", "started", "error", "done"]
    required: yes
    index: yes
  result:
    type: String

JobSchema.plugin(EntitySchemaPlugin)

module.exports = JobSchema
