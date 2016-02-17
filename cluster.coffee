cluster = require('cluster')
winston = require('winston')

config = require('config')
startServer = require('./server')


if cluster.isMaster
  number = parseInt(process.env.WORKERS or config.server.workers, 10)

  while number--
    winston.info("Starting worker: #{config.server.workers - number}")
    cluster.fork()

  cluster.on('exit', (worker, code, signal) ->
    winston.error("Worker #{worker.process.pid} died")

    if config.debug
      process.exit()
    else
      cluster.fork()
  )

else
  startServer()
