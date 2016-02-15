module.exports =
  server:
    workers: parseInt(process.env.WORKERS, 10) or 1
    port: parseInt(process.env.PORT, 10) or 3000
    host: '127.0.0.1'
    death_timeout: 5000
