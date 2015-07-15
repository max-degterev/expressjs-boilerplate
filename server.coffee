#=========================================================================================
# Application setup
#=========================================================================================
config = require('config')
cluster = require('cluster')
log = require('app/common/helpers').log
server = require('app/server')

if cluster.isMaster
  num = parseInt(process.env.WORKERS, 10) or config.workers

  for i in [1..num]
    log("Starting worker #{i}", 'cyan')
    cluster.fork()

  cluster.on 'exit', (worker, code, signal)->
    log("Worker #{worker.process.pid} died", 'red bold')

    if config.debug
      process.exit()
    else
      cluster.fork()

else
  server.start()
