# TODO move this config object to a file
config =
  PORT: 3000
  CLUSTER_ENABLED: yes
  CLUSTER_WORKERS: 2
  MONGO_URL: "" # add your mongodb's url
require("./private/app")(config)
