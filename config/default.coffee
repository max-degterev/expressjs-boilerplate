module.exports =
  host: 'example.dev'
  server:
    workers: 1
    port: parseInt(process.env.PORT, 10) or 3000
    ip: '127.0.0.1'
    death_timeout: 5000

  build:
    source_maps: false
    livereload: false

  server_only_keys: [
    'server_only_keys'
    'build'
  ]

  ga_id: 'UA-XXXXXXX-X'
