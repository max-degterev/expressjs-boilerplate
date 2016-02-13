#=========================================================================================
# Application setup
#=========================================================================================
# cluster = require('cluster')
# config = require('config')
# log = require('./lib/logger')
# server = require('./app/server')

# if cluster.isMaster
#   num = parseInt(process.env.WORKERS or config.server.workers, 10) + 1

#   while num -= 1
#     log("Starting worker #{config.server.workers - num + 1}", 'cyan')
#     cluster.fork()

#   cluster.on('exit', (worker, code, signal) ->
#     log("Worker #{worker.process.pid} died", 'red bold')

#     if config.debug
#       process.exit()
#     else
#       cluster.fork()
#   )

# else
#   server.start()

console.warn 'WOW!'
