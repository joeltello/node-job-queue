mongoose = require("mongoose")
JobSchema = require("./schemas/JobSchema")

Job = mongoose.model('Job', JobSchema)

module.exports = Job