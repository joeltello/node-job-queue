### Install dependencies
`npm install`
### Run project
`npm start`

#### This demo requires a redis server running (job queue is stored in redis). It currently uses the client default settings:

PORT: 6379

HOST: 127.0.0.1

#### It also requires a Mongo database to store the job documents.

*** To change the configuration to use your own Redis and Mongo servers ADD a settings file `config.json` in the root folder.

development | production => process.env.NODE_ENV (`private/lib/config.coffee`)

```
{
  "development": {
    "PORT": 3001,
    "CLUSTER_ENABLED": true,
    "CLUSTER_WORKERS": 2,
    "MONGO_URL": "", // MongoDB connection
    "PARALLEL_JOBS": 100,
    "REDIS": {
      "HOST": "127.0.0.1", // Redis Host
      "PORT": 6379 // Redis Port
    }
  },
  "production": {}
}
```

### RESTful API
`POST /api/1.0/jobs`

body = {url: "http://www.google.com"}

`GET /api/1.0/jobs/:id`

### Roadmap
- unit testing
- better error handling (large files)
- error recovery
