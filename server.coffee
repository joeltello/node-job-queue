# TODO move this config object to a file
config =
  PORT: 3000
  CLUSTER_ENABLED: yes
  CLUSTER_WORKERS: 2
  MONGO_URL: "mongodb://test:mex1029384756ico@ds017165.mlab.com:17165/test-db" # add your mongodb's url
require("./private/app")(config)
